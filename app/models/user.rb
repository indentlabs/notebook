require 'digest/md5'

##
# a person using the Indent web application. Owns all other content.
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, 
         :omniauthable, :omniauth_providers => [:google_oauth2]

  # validates :name,  presence: true
  validates :email, presence: true

  has_many :characters
  has_many :items
  has_many :locations
  has_many :universes

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

  def content
    {
      characters: characters,
      items: items,
      locations: locations,
      universes: universes
    }
  end

  def content_count
    [
      characters.length,
      items.length,
      locations.length,
      universes.length
    ].sum
  end

  def public_content_count
    [
      characters.is_public.length,
      items.is_public.length,
      locations.is_public.length,
      universes.is_public.length
    ].sum
  end

  def image_url(size=80)
    email_md5 = Digest::MD5.hexdigest(email.downcase)
    # 80px is Gravatar's default size
    "https://www.gravatar.com/avatar/#{email_md5}?d=identicon&s=#{size}".html_safe
  end


  # To find a user based on auth data from another provider
  def self.find_by_omniauth(access_token)
    data = access_token.info

    print "find by omniauth"
    print data.inspect

    user = User.where(:email => data["email"]).first

    # create if user doesn't exist
    unless user
      user = User.create(
        name: data['name'],
        email: data["email"],
        password: Devise.friendly_token[0,20]
      )
    end

    user
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
