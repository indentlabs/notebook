require 'active_support/concern'

# Remembers which password protected documents this visitor has entered the password for.
# The session is a 4KB cookie that everything else shares, so it only holds a short fingerprint
# for each of the most recent few documents. Signing out clears them along with the session.
module DocumentUnlocks
  extend ActiveSupport::Concern

  MAX_REMEMBERED_UNLOCKS = 20

  included do
    helper_method :document_locked?
  end

  private

  # Whether this viewer gets a lock instead of the document's title and text
  def document_locked?(document)
    document.password_protected? &&
      !document.readable_by?(current_user || User.new) &&
      !document_unlocked?(document)
  end

  def document_unlocked?(document)
    return false unless document.password_protected?

    remembered = session[:unlocked_documents].to_h[document.id.to_s]
    remembered.present? && ActiveSupport::SecurityUtils.secure_compare(remembered, document.password_fingerprint)
  end

  def remember_document_unlock(document)
    unlocks = session[:unlocked_documents].to_h.except(document.id.to_s)
    unlocks[document.id.to_s] = document.password_fingerprint

    session[:unlocked_documents] = unlocks.to_a.last(MAX_REMEMBERED_UNLOCKS).to_h
  end
end
