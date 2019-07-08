##
# a person using the Notebook.ai web application. Owns all other content.
class User < ApplicationRecord
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  include HasContent
  include Authority::UserAbilities

  validates :username, 
    uniqueness: { case_sensitive: false },
    allow_nil: true,
    allow_blank: true,
    length: { maximum: 40 },
    format: /\A[A-Za-z0-9\-_\$\+\!\*]+\z/

  has_many :subscriptions, dependent: :destroy
  has_many :billing_plans, through: :subscriptions
  def on_premium_plan?
    BillingPlan::PREMIUM_IDS.include?(self.selected_billing_plan_id)
  end
  has_many :promotions


  has_many :image_uploads

  has_one :referral_code, dependent: :destroy
  has_many :referrals, foreign_key: :referrer_id, dependent: :destroy
  def referrer
    referral = Referral.find_by(referred_id: self.id)
    referral.referrer unless referral.nil?
  end

  has_many :votes,                        dependent: :destroy
  has_many :raffle_entries,               dependent: :destroy

  has_many :content_change_events,        dependent: :destroy
  has_many :page_tags,                    dependent: :destroy

  has_many :user_content_type_activators, dependent: :destroy

  has_many :api_keys,                     dependent: :destroy

  has_many :notice_dismissals,            dependent: :destroy

  def contributable_universes
    @user_contributable_universes ||= begin
      # todo email confirmation needs to happy for data safety / privacy (only verified emails)
      contributor_ids = Contributor.where('email = ? OR user_id = ?', self.email, self.id).pluck(:universe_id)

      Universe.where(id: contributor_ids)
    end
  end

  #TODO: rename this to #{content_type}_shared_with_me and only return contributable content that others own
  Rails.application.config.content_types[:all_non_universe].each do |content_type|
    pluralized_content_type = content_type.name.downcase.pluralize
    define_method "contributable_#{pluralized_content_type}" do
      contributable_universe_ids = contributable_universes.pluck(:id)

      content_type.where(universe_id: contributable_universe_ids)
                  .where.not(user_id: self.id)
    end
  end

  #TODO: rename this to the more descriptive name contributable_#{content_type}
  # returns all content of that type that a user can edit/contribute to, even if it's not owned by the user
  Rails.application.config.content_types[:all_non_universe].each do |content_type|
    pluralized_content_type = content_type.name.downcase.pluralize
    define_method "linkable_#{pluralized_content_type}" do
      my_universe_ids = universes.pluck(:id)
      contributable_universe_ids = contributable_universes.pluck(:id)

      content_type.where("""
        universe_id IN (#{(my_universe_ids + contributable_universe_ids + [0]).uniq.join(',')})
          OR
        (universe_id IS NULL AND user_id = #{self.id.to_i})
      """)
    end
  end

  def linkable_universes
    my_universe_ids = universes.pluck(:id)
    contributable_universe_ids = contributable_universes.pluck(:id)

    Universe.where(id: my_universe_ids + contributable_universe_ids)
  end

  has_many :documents, dependent: :destroy

  after_create :initialize_stripe_customer, unless: -> { Rails.env == 'test' }
  after_create :initialize_referral_code
  after_create :initialize_secure_code
  after_create :initialize_content_type_activators
  # TODO we should do this, but we need to figure out how to make it fast first
  # after_create :initialize_categories_and_fields

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
    require 'digest/md5'

    email_md5 = Digest::MD5.hexdigest(email.downcase)
    # 80px is Gravatar's default size
    "https://www.gravatar.com/avatar/#{email_md5}?d=identicon&s=#{size}".html_safe
  end

  # TODO these (3) can probably all be scopes on the related object, no?
  def active_subscriptions
    subscriptions
      .where('start_date < ?', Time.now)
      .where('end_date > ?',   Time.now)
  end

  def active_billing_plans
    billing_plan_ids = active_subscriptions.pluck(:billing_plan_id)
    BillingPlan.where(id: billing_plan_ids).uniq
  end

  def active_promotions
    promotions.active
  end

  def active_promo_codes
    PageUnlockPromoCode.where(id: active_promotions.pluck(:page_unlock_promo_code_id))
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

  def self.from_api_key(key)
    found_key = ApiKey.includes(:user).find_by(key: key)
    return nil unless found_key.present?

    found_key.user
  end

  def profile_url
    if self.username.present?
      Rails.application.routes.url_helpers.profile_by_username_path(username: self.username)
    else
      Rails.application.routes.url_helpers.user_path(id: self.id)
    end
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
end
