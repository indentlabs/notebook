require 'active_support/concern'

module HasPrivacy
  extend ActiveSupport::Concern

  included do
    scope :is_public, -> do
      # self is an AR relation, so we use klass to get the class of the relation model
      if self.klass == Universe
        where(privacy: 'public')
      else
        # A password outranks a public universe, so protected pages don't come along with it.
        # Spelled out so that pages with no privacy value at all still do.
        table = self.name.pluralize
        eager_load(:universe).where(
          "#{table}.privacy = ? OR (universes.privacy = ? AND (#{table}.privacy IS NULL OR #{table}.privacy != ?))",
          'public', 'public', 'password'
        )
      end
    end

    def private_content?
      !public_content?
    end

    def public_content?
      return false if try(:password_protected?)

      universe_is_public = respond_to?(:universe) && universe.present? && universe.public_content?
      privacy == 'public' || universe_is_public
    end
  end
end
