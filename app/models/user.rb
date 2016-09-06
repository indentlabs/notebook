##
# a person using the Indent web application. Owns all other content.
class User < ActiveRecord::Base
  include PragmaticContext::Contextualizable
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

  # Used for JSON-LD generation
  contextualize_as_type 'http://schema.org/Person'
  contextualize_with_id { |user| Rails.application.routes.url_helpers.user_url(user) }
  contextualize :name, :as => 'http://schema.org/alternateName'
  contextualize :email, :as => 'http://schema.org/email'

  # as_json would try to print the password digest, which requires authentication
  def as_json(options={})
    excludes = [:password_digest, :old_password]
    options = {} if options.nil?
    options[:except] ||= excludes
    super(options)
  end

  def to_json(options={})
    options[:except] ||= [:password_digest, :old_password]
    super(options)
  end

  # We have "as_json," "to_json," and "to_xml" to worry about. "to_json" doesn't print passwords

  def to_xml(options={})
    options[:except] ||= [:password_digest, :old_password]
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
end
