require 'active_support/concern'

# Remembers which password protected pages (characters, locations, universes, and so on) this visitor
# has entered the password for. Works like DocumentUnlocks: the session is a 4KB cookie that everything
# else shares, so it only holds a short fingerprint for each of the most recent few pages, and signing
# out clears them along with the session.
module PageUnlocks
  extend ActiveSupport::Concern

  MAX_REMEMBERED_UNLOCKS = 20

  private

  # Whether this viewer gets a lock screen instead of the page
  def page_locked?(page)
    page.try(:password_protected?) &&
      !page.readable_by?(current_user || User.new) &&
      !page_unlocked?(page)
  end

  def page_unlocked?(page)
    return false unless page.try(:password_protected?)

    remembered  = session[:unlocked_pages].to_h[page_unlock_key(page)]
    fingerprint = page.password_fingerprint
    remembered.present? && fingerprint.present? && ActiveSupport::SecurityUtils.secure_compare(remembered, fingerprint)
  end

  def remember_page_unlock(page)
    key = page_unlock_key(page)
    unlocks = session[:unlocked_pages].to_h.except(key)
    unlocks[key] = page.password_fingerprint

    session[:unlocked_pages] = unlocks.to_a.last(MAX_REMEMBERED_UNLOCKS).to_h
  end

  def page_unlock_key(page)
    "#{page.class.name}-#{page.id}"
  end
end
