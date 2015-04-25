require 'active_support/concern'

# Model is either public or private
module HasPrivacy
  extend ActiveSupport::Concern

  def private?
    return universe.privacy.downcase == 'private' if universe && universe.privacy
    return privacy == 'private' if privacy
    true
  end

  def public?
    !self.private?
  end
end
