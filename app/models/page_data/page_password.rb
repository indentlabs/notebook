# The password for a password protected page. It lives in its own table, rather than a column on each
# page type's table, so nothing that serializes a page's columns can ever include the digest.
# Pages change it only through HasPasswordProtection#protect_with_password and #remove_password_protection.
class PagePassword < ApplicationRecord
  belongs_to :page, polymorphic: true

  # Length rules live on the page, which knows whether a new password is being set
  has_secure_password validations: false

  validates :password_digest, presence: true

  # Stays out of the logs and any accidental #inspect of a page's associations
  def inspect
    "#<PagePassword id: #{id.inspect}, page_type: #{page_type.inspect}, page_id: #{page_id.inspect}>"
  end

  def serializable_hash(options = nil)
    options = (options || {}).dup
    options[:except] = Array(options[:except]) + ['password_digest']
    super(options)
  end
end
