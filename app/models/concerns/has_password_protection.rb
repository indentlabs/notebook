require 'active_support/concern'

# Lets a page's owner protect it with a password: a third privacy value, 'password', that is private
# everywhere on the site except the page itself, which anyone with the password can read.
#
# Everything that checks for privacy == 'public' already treats a protected page as private. The places
# that grant access some other way, like a public universe, check #password_protected? first.
# Readers who have entered the password are tracked in their session by PageUnlocks.
#
# Modelled on Document's password protection (see Document#protect_with_password).
module HasPasswordProtection
  extend ActiveSupport::Concern

  PRIVACY_LABELS = {
    'private'  => 'Private',
    'public'   => 'Public',
    'password' => 'Password protected'
  }.freeze

  # bcrypt ignores everything past 72 bytes
  PASSWORD_LENGTH = 5..72

  included do
    has_one :page_password, as: :page, inverse_of: :page, autosave: true

    # Pages are soft deleted and can be restored from the trash, so the password has to outlive a delete
    after_real_destroy { PagePassword.where(page_type: self.class.name, page_id: id).delete_all }

    # Only checked when privacy changes, so a row with an old or unexpected value can still be saved
    validates :privacy, inclusion: { in: PRIVACY_LABELS.keys }, allow_blank: true, if: :will_save_change_to_privacy?
    validate :password_protection_changed_explicitly, if: :will_save_change_to_privacy?
    # A new password gets the friendlier length message instead
    validate :protected_page_has_a_password, if: -> { @new_page_password.nil? && password_protected? }
    validate :new_password_is_a_reasonable_length, if: -> { !@new_page_password.nil? && password_protected? }
  end

  def password_protected?
    privacy == 'password'
  end

  def privacy_label
    PRIVACY_LABELS.fetch(privacy, PRIVACY_LABELS['private'])
  end

  def privacy_icon
    { 'public' => 'public', 'password' => 'vpn_key' }.fetch(privacy, 'lock')
  end

  # Password protection only ever changes through these two methods, so nothing that does a routine
  # update(privacy: 'public'), like sharing a page or submitting it to a collection, can quietly take it off.
  def protect_with_password(password)
    change_password_protection do
      @new_page_password = password.to_s

      self.privacy = 'password'
      # A blank password is a no-op for has_secure_password, so the length check above is what rejects it
      (page_password || build_page_password).password = @new_page_password
      save
    end
  ensure
    @new_page_password = nil
  end

  def remove_password_protection(new_privacy)
    change_password_protection do
      self.privacy = new_privacy
      page_password&.mark_for_destruction
      save
    end
  end

  def authenticate_page_password(password)
    return false unless password_protected? && page_password.present?

    page_password.authenticate(password.to_s).present?
  end

  # What a reader's session keeps after they enter the password. It's tied to the digest, so setting
  # a new password locks out everyone who entered the old one.
  def password_fingerprint
    digest = page_password&.password_digest
    return if digest.blank?

    OpenSSL::HMAC.hexdigest('SHA256', Rails.application.secret_key_base, "#{self.class.name}/#{id}/#{digest}").first(16)
  end

  private

  def change_password_protection
    @changing_password_protection = true
    yield
  ensure
    @changing_password_protection = false
  end

  def password_protection_changed_explicitly
    return if @changing_password_protection
    return unless privacy_in_database == 'password' || password_protected?

    errors.add(:privacy, "can't be changed to or from password protected here")
  end

  def protected_page_has_a_password
    return if page_password.present? && !page_password.marked_for_destruction? && page_password.password_digest.present?

    errors.add(:password, "can't be blank")
  end

  def new_password_is_a_reasonable_length
    if @new_page_password.length < PASSWORD_LENGTH.min
      errors.add(:password, "must be at least #{PASSWORD_LENGTH.min} characters")
    elsif @new_page_password.bytesize > PASSWORD_LENGTH.max
      errors.add(:password, "must be at most #{PASSWORD_LENGTH.max} characters")
    end
  end
end
