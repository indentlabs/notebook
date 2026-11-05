# Per-request state, reset automatically before every request.
class Current < ActiveSupport::CurrentAttributes
  # The one password protected page this request's reader has entered the password for. Only
  # ContentController#show sets it, and only the page authorizers honor it, for that exact page.
  # Everything else on the site, including every other request, keeps treating the page as private.
  attribute :unlocked_page

  def self.unlocked_page?(page)
    unlocked = unlocked_page
    unlocked.present? && page.present? && unlocked.class == page.class && unlocked.id == page.id
  end
end
