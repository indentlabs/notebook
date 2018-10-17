require 'active_support/concern'

module HasContent
  extend ActiveSupport::Concern

  included do
    Rails.application.config.content_types[:all].each do |content_type|
      content_type_sym = content_type.name.downcase.pluralize.to_sym # :characters

      #has_many :characters, :locations, etc
      has_many content_type_sym, dependent: :destroy
    end

    has_many :attribute_fields
    has_many :attribute_categories
    has_many :attribute_values, class_name: 'Attribute', dependent: :destroy

    # {
    #   characters: [...],
    #   locations:  [...]
    # }
    def content(
      content_types: Rails.application.config.content_types[:all].map(&:name),
      page_scoping:  { user_id: self.id }
    )
      @user_content ||= content_list(page_scoping: page_scoping, content_types: content_types).group_by(&:page_type)
    end

    # [..., ...]
    def content_list(
      content_types: Rails.application.config.content_types[:all].map(&:name),
      page_scoping:  { user_id: self.id }
    )
      polymorphic_content_fields = [:id, :name, :page_type, :user_id, :universe_id, :created_at, :updated_at, :deleted_at, :privacy]

      chained_query = nil
      (content_types + ["ContentPage"]).each do |content_type|
        content_type_class = content_type.constantize
        if chained_query.nil?
          chained_query = content_type_class.select(*polymorphic_content_fields).where(page_scoping)
        else
          chained_query = content_type_class.select(*polymorphic_content_fields).where(page_scoping).union(chained_query)
        end
      end

      @user_content_list ||= chained_query
    end

    # {
    #   characters: [...],
    #   locations:  [...]
    # }
    def content_in_universe universe_id
      @user_content_in_universe ||= content_list(page_scoping: { user_id: self.id, universe_id: universe_id }).group_by(&:page_type)
    end

    # 5
    def content_count
      @user_content_count ||= content_list.count
    end

    # {
    #  characters: [...],
    #  locations:  [...],
    # }
    def public_content
      @user_public_content ||= begin
        content_value = {}

        Rails.application.config.content_types[:all].each do |type|
          relation = type.name.downcase.pluralize.to_sym # :characters
          content_value[relation] = send(relation).is_public
        end

        content_value
      end
    end

    # 8
    def public_content_count
      @user_content_count ||= begin
        Rails.application.config.content_types[:all].map do |type|
          relation = type.name.downcase.pluralize.to_sym # :characters
          send(relation).is_public.count
        end.sum
      end
    end

    # [..., ..., ...]
    def recent_content_list
      # Todo: I think this is more optimized, but the group introduces weird
      # ordering of the results, so we're building it a bit less optimized below
      # just to ensure it's actually correct.
      # recently_changed_attributes = Attribute.where(user: self)
      #                                        .order('updated_at desc')
      #                                        .group([:entity_type, :entity_id])
      #                                        .limit(10)

      recently_changed_attributes = Attribute.where(user: self)
                                             .order('updated_at desc')
                                             .limit(100)
                                             .group_by { |r| [r.entity_type, r.entity_id] }
                                             .keys
                                             .first(10)

      @user_recent_content_list = recently_changed_attributes.map do |entity_type, entity_id|
        entity_type.constantize.find_by(id: entity_id)
      end.compact
    end
  end
end
