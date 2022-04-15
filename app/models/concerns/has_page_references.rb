require 'active_support/concern'

module HasPageReferences
  extend ActiveSupport::Concern

  included do
    # Pages that reference this one
    has_many :incoming_page_references, 
              as:          :referenced_page,
              class_name:  PageReference.name,
              dependent:   :destroy
    Rails.application.config.content_type_names[:all].each do |page_type|
      has_many "referencing_#{page_type.downcase}_pages".to_sym,
        through:     :incoming_page_references,
        source:      :referencing_page,
        source_type: page_type
    end
    def referencing_pages
      # Build list of all types of referencing pages
      pages = []
      Rails.application.config.content_type_names[:all].each do |page_type|
        pages[page_type] << send("referencing_#{page_type.downcase}_pages").to_a
      end
      pages
    end

    # Pages referenced by this one
    has_many :outgoing_page_references,
              as:         :referencing_page,
              class_name: PageReference.name,
              dependent:  :destroy
    Rails.application.config.content_type_names[:all].each do |page_type|
      has_many "referenced_#{page_type.downcase}_pages".to_sym,
        through:     :outgoing_page_references,
        source:      :referenced_page,
        source_type: page_type
    end
    def referenced_pages
      # Build list of all types of referenced pages
      pages = []
      Rails.application.config.content_type_names[:all].each do |page_type|
        pages[page_type] << send("referenced_#{page_type.downcase}_pages").to_a
      end
      pages
    end
  end
end
