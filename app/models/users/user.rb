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
    format: /\A[A-Za-z0-9\-_\$\+\!\*]+\z/,
  if: Proc.new { |user| user.username_changed?}
  
  validates :forums_badge_text,
    allow_nil: true,
    allow_blank: true,
    length: { maximum: 20 },
  if: Proc.new { |user| user.forums_badge_text_changed? }

  has_many :folders
  has_many :subscriptions, dependent: :destroy
  has_many :billing_plans, through: :subscriptions
  def on_premium_plan?
    BillingPlan::PREMIUM_IDS.include?(self.selected_billing_plan_id) || active_promo_codes.any?
  end
  has_many :promotions, dependent: :destroy
  has_many :paypal_invoices
  has_many :page_unlock_promo_codes, through: :paypal_invoices

  has_many :image_uploads, dependent: :destroy

  has_many :contributors, dependent: :destroy

  has_one :referral_code, dependent: :destroy
  has_many :referrals, foreign_key: :referrer_id, dependent: :destroy
  def referrer
    referral = Referral.find_by(referred_id: self.id)
    referral.referrer unless referral.nil?
  end

  has_many :user_followings,              dependent: :destroy
  has_many :followed_users, -> { distinct }, through: :user_followings, source: :followed_user
  # has_many :followed_by_users,            through: :user_followings, source: :user # todo unsure how to actually write this, so we do it manually below
  def followed_by_users
    User.where(id: UserFollowing.where(followed_user_id: self.id).pluck(:user_id)) 
  end
  def followed_by?(user)
    followed_by_users.pluck(:id).include?(user.id)
  end

  has_many :user_blockings,               dependent: :destroy
  has_many :blocked_users,                through: :user_blockings, source: :blocked_user
  def blocked_by_users
    User.where(id: UserBlocking.where(blocked_user_id: self.id).pluck(:user_id))    
  end
  def blocked_by?(user)
    blocked_by_users.pluck(:id).include?(user.id)
  end

  has_many :content_page_shares,           dependent: :destroy
  has_many :content_page_share_followings, dependent: :destroy
  has_many :content_page_share_reports,    dependent: :destroy

  has_many :page_collections,              dependent: :destroy
  has_many :page_collection_submissions,   dependent: :destroy
  def published_in_page_collections
    ids = page_collection_submissions.accepted.pluck(:page_collection_id)
    @published_in_page_collections ||= PageCollection.where(id: ids)
  end
  has_many :page_collection_followings,    dependent: :destroy
  has_many :followed_page_collections,     through: :page_collection_followings, source: :page_collection
  has_many :page_collection_reports,       dependent: :destroy

  has_many :votes,                         dependent: :destroy
  has_many :raffle_entries,                dependent: :destroy

  has_many :content_change_events,         dependent: :destroy
  has_many :page_tags,                     dependent: :destroy

  has_many :user_content_type_activators,  dependent: :destroy

  has_many :api_keys,                      dependent: :destroy

  has_many :notifications,                 dependent: :destroy
  has_many :notice_dismissals,             dependent: :destroy

  has_many :page_settings_overrides,       dependent: :destroy
  has_one_attached :avatar
  validates :avatar, attached: false,
    content_type: {
      in: ['image/png', 'image/jpg', 'image/jpeg', 'image/gif'],
      message: 'must be a PNG, JPG, JPEG, or GIF'
    },
    dimension: { 
      width: { max: 1000 },
      height: { max: 1000 }, 
      message: 'must be smaller than 1000x1000 pixels'
    },
    size: { 
      less_than: 500.kilobytes, 
      message: "can't be larger than 500KB"
    }

  has_many :application_integrations

  def my_universe_ids
    @cached_universe_ids ||= universes.pluck(:id)
  end

  def contributable_universes
    @cached_user_contributable_universes ||= Universe.where(id: contributable_universe_ids)
  end

  def linkable_universes
    @cached_linkable_universes ||= Universe.where(id: my_universe_ids + contributable_universes)
  end

  def contributable_universe_ids
    # TODO: email confirmation needs to happen for data safety / privacy (only verified emails)
    @contributable_universe_ids ||= Contributor.where('email = ? OR user_id = ?', self.email, self.id).pluck(:universe_id)
  end

  # TODO: rename this to #{content_type}_shared_with_me
  Rails.application.config.content_types[:all_non_universe].each do |content_type|
    pluralized_content_type = content_type.name.downcase.pluralize
    define_method "contributable_#{pluralized_content_type}" do
      content_type.where(universe_id: contributable_universe_ids)
                  .where.not(user_id: self.id)
    end
  end

  # TODO: rename this to the more descriptive name contributable_#{content_type} (except currently in use lol)
  # returns all content of that type that a user can edit/contribute to, even if it's not owned by the user
  Rails.application.config.content_types[:all_non_universe].each do |content_type|
    pluralized_content_type = content_type.name.downcase.pluralize
    define_method "linkable_#{pluralized_content_type}" do
      # We append [0] to the ID list here in case both sets are empty, since IN () is invalid syntax but IN(0) is [and has the same result]
      content_type.where("""
        universe_id IN (#{(my_universe_ids + contributable_universe_ids + [-1]).uniq.join(',')})
          OR
        (universe_id IS NULL AND user_id = #{self.id.to_i})
      """).where(archived_at: nil)
    end
  end

  def linkable_documents
    Document.where("""
      universe_id IN (#{(my_universe_ids + contributable_universe_ids + [-1]).uniq.join(',')})
        OR
      (universe_id IS NULL AND user_id = #{self.id.to_i})
    """)
  end

  def linkable_timelines
    Timeline.where("""
      universe_id IN (#{(my_universe_ids + contributable_universe_ids + [-1]).uniq.join(',')})
        OR
      (universe_id IS NULL AND user_id = #{self.id.to_i})
    """).where(archived_at: nil)
  end

  has_many :documents, dependent: :destroy

  after_create :initialize_stripe_customer, unless: -> { Rails.env == 'test' }
  after_create :initialize_referral_code
  after_create :initialize_secure_code
  after_create :initialize_content_type_activators
  after_create :follow_andrew # <3

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
    if avatar.attached? # manually-uploaded avatar
      Rails.application.routes.url_helpers.rails_representation_url(avatar.variant(resize_to_limit: [size, size]).processed, only_path: true)

    else # otherwise, grab the default from Gravatar for this email address
      gravatar_fallback_url(size)
    end

  rescue ActiveStorage::FileNotFoundError
    gravatar_fallback_url(size)

  rescue ImageProcessing::Error
    gravatar_fallback_url(size)
  end

  def gravatar_fallback_url(size=80)
    require 'digest/md5' # todo do we actually need to require this all the time?
    email_md5 = Digest::MD5.hexdigest(email.downcase)
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

  def follow_andrew
    andrew = User.find_by(id: 5)
    return unless andrew.present?

    followed_users << andrew
    save
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

  def display_name
    username = self.username.present? ? "@#{self.username}" : nil
    username ||= self.name.present? ? self.name : nil
    username ||= 'Anonymous Author'

    username
  end
  def forum_username
    display_name
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

  def self.icon
    'person'
  end

  def self.color
    'green'
  end

  def self.text_color
    'green-text'
  end

  def favorite_page_type_color
    return User.color unless favorite_page_type? && Rails.application.config.content_types[:all].map(&:name).include?(favorite_page_type)
    
    favorite_page_type.constantize.color
  end

  def favorite_page_type_icon
    return User.icon unless favorite_page_type? && Rails.application.config.content_types[:all].map(&:name).include?(favorite_page_type)
    
    favorite_page_type.constantize.icon
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
