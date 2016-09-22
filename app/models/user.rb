require 'digest/md5'

##
# a person using the Indent web application. Owns all other content.
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # validates :name,  presence: true
  validates :email, presence: true

  has_many :characters
  has_many :items
  has_many :languages
  has_many :locations
  has_many :magics
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

  def content
    {
      characters: characters,
      items: items,
      languages: languages,
      locations: locations,
      magics: magics,
      universes: universes
    }
  end

  def content_count
    [
      characters.length,
      items.length,
      languages.length,
      locations.length,
      magics.length,
      universes.length
    ].sum
  end

  def image_url(size=80)
    email_md5 = Digest::MD5.hexdigest(email.downcase)
    # 80px is Gravatar's default size
    "https://www.gravatar.com/avatar/#{email_md5}?d=identicon&s=#{size}"
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
