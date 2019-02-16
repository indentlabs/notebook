require 'active_support/concern'

module HasPageTags
  extend ActiveSupport::Concern

  included do
    has_many :page_tags, as: :page
  end
end
