require 'digest/md5'

##
# a person using the Notebook.ai web application. Owns all other content.
class User < ActiveRecord::Base
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  include HasContent
  include Authority::UserAbilities

  validates_uniqueness_of :username, allow_nil: true, allow_blank: true

  has_many :subscriptions
  has_many :billing_plans, through: :subscriptions
  def on_premium_plan?
    BillingPlan::PREMIUM_IDS.include?(self.selected_billing_plan_id)
  end

  has_many :image_uploads

  has_one :referral_code
  has_many :referrals, foreign_key: :referrer_id
  def referrer
    referral = Referral.find_by(referred_id: self.id)
    referral.referrer unless referral.nil?
  end

  has_many :votes
  has_many :raffle_entries

  has_many :content_change_events

  has_many :user_content_type_activators

  def contributable_universes
    # todo email confirmation needs to happy for data safety / privacy (only verified emails)
    contributor_by_email = Contributor.where(email: self.email).pluck(:universe_id)
    contributor_by_user = Contributor.where(user: self).pluck(:universe_id)

    Universe.where(id: contributor_by_email + contributor_by_user)
  end
  Rails.application.config.content_types[:all_non_universe].each do |content_type|
    pluralized_content_type = content_type.name.downcase.pluralize
    define_method "contributable_#{pluralized_content_type}" do
      contributable_universes.flat_map do |universe|
        universe.send(pluralized_content_type).where.not(user_id: self.id)
      end
    end
  end

  # TODO: Swap this out with a has_many when we transition from a scratchpad to users having multiple documents
  has_one :document

  after_create :initialize_stripe_customer, unless: -> { Rails.env == 'test' }
  after_create :initialize_referral_code
  after_create :initialize_secure_code
  after_create :initialize_content_type_activators

  def createable_content_types
    Rails.application.config.content_types[:all].select { |c| can_create? c }
  end

  # as_json creates a hash structure, which you then pass to ActiveSupport::json.encode to actually encode the object as a JSON string.
  # This is different from to_json, which  converts it straight to an escaped JSON string,
  # which is undesireable in a case like this, when we want to modify it
  def as_json(options={})
    options[:except] ||= blacklisted_attributes
    super(options)
  end

  # Returns this object as an escaped JSON string
  def to_json(options={})
    options[:except] ||= blacklisted_attributes
    super(options)
  end

  def to_xml(options={})
    options[:except] ||= blacklisted_attributes
    super(options)
  end

  def name
    self[:name].blank? && self.persisted? ? 'Anonymous author' : self[:name]
  end

  def image_url(size=80)
    email_md5 = Digest::MD5.hexdigest(email.downcase)
    # 80px is Gravatar's default size
    "https://www.gravatar.com/avatar/#{email_md5}?d=identicon&s=#{size}".html_safe
  end

  def active_subscriptions
    subscriptions
      .where('start_date < ?', Time.now)
      .where('end_date > ?',   Time.now)
  end

  def active_billing_plans
    active_subscriptions
      .map { |subscription| subscription.billing_plan }
      .uniq
  end

  def initialize_stripe_customer
    if self.stripe_customer_id.nil?
      customer_data = Stripe::Customer.create(email: self.email)

      self.stripe_customer_id = customer_data.id
      self.save

      # If we're creating this Customer in Stripe for the first time, we should also associate them with the free tier
      Stripe::Subscription.create(customer: self.stripe_customer_id, plan: 'starter')
    end

    self.stripe_customer_id
  end

  def initialize_referral_code
    ReferralCode.create(user: self, code: SecureRandom.uuid)
  end

  def initialize_secure_code
    update(secure_code: SecureRandom.uuid) unless secure_code.present?
  end

  def initialize_content_type_activators
    to_activate = Rails.application.config.content_types[:always_on] + Rails.application.config.content_types[:default_on]

    to_activate.uniq.each do |content_type|
      user_content_type_activators.create(content_type: content_type.name)
    end
  end

  def update_without_password(params, *options)
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    if params[:username].blank?
      params.delete(:username)
    end

    result = update_attributes(params, *options)
    clean_up_passwords
    result
  end

  def forum_username
    username = self.username.present? ? "@#{self.username}" : nil
    username ||= self.name.present? ? self.name : nil
    username ||= 'Anonymous Author'

    username
  end

  private

  # Attributes that are non-public, and should be blacklisted from any public
  # export (ex. in the JSON api, or SEO meta info about the user)
  def blacklisted_attributes
    [
      :password_digest,
      :old_password,
      :encrypted_password,
      :reset_password_token,
      :email
    ]
  end

  def deleted_at
    nil #hack
  end
end
