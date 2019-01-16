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
      return {} if content_types.empty?

      polymorphic_content_fields = [:id, :name, :page_type, :user_id, :created_at, :updated_at, :deleted_at, :privacy]
      where_conditions = page_scoping.map { |key, value| "#{key} = #{value}" }.join(' AND ') + ' AND deleted_at IS NULL'

      sql = content_types.uniq.map do |page_type|
        "SELECT #{polymorphic_content_fields.join(',')} FROM #{page_type.downcase.pluralize} WHERE #{where_conditions}"
      end.join(' UNION ALL ') + ' ORDER BY page_type, id'

      res = ActiveRecord::Base.connection.execute(sql)
      @content_by_page_type ||= res.to_a.each_with_object({}) do |object, hash|
        object.keys.each do |key|
          object.except!(key) if key.is_a?(Integer)
        end

        hash[object['page_type']] ||= []
        hash[object['page_type']] << ContentPage.new(object)
      end
    end

    # [..., ...]
    def content_list(
      content_types: Rails.application.config.content_types[:all].map(&:name),
      page_scoping:  { user_id: self.id }
    )

      # todo we can't select for universe_id here which kind of sucks, so we need to research 1) the repercussions, 2) what to do instead
      polymorphic_content_fields = [:id, :name, :page_type, :user_id, :created_at, :updated_at, :deleted_at, :privacy]
      where_conditions = page_scoping.map { |key, value| "#{key} = #{value}" }.join(' AND ') + ' AND deleted_at IS NULL'

      sql = content_types.uniq.map do |page_type|
        "SELECT #{polymorphic_content_fields.join(',')} FROM #{page_type.downcase.pluralize} WHERE #{where_conditions}"
      end.join(' UNION ALL ')

      @user_content_list ||= ActiveRecord::Base.connection.execute(sql)
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
    def recent_content_list(limit: 10)
      # Todo: I think this is more optimized, but the group introduces weird
      # ordering of the results, so we're building it a bit less optimized below
      # just to ensure it's actually correct.
      # recently_changed_attributes = Attribute.where(user: self)
      #                                        .order('updated_at desc')
      #                                        .group([:entity_type, :entity_id])
      #                                        .limit(10)

      recently_changed_attributes = Attribute.where(user: self)
                                             .order('updated_at desc')
                                             .limit(limit * 100)
                                             .group_by { |r| [r.entity_type, r.entity_id] }
                                             .keys
                                             .first(limit)

      @user_recent_content_list = recently_changed_attributes.map do |entity_type, entity_id|
        entity_type.constantize.find_by(id: entity_id)
      end.compact
    end

    def recent_content_list_by_create(limit: 10)
      # Todo: I think this is more optimized, but the group introduces weird
      # ordering of the results, so we're building it a bit less optimized below
      # just to ensure it's actually correct.
      # recently_changed_attributes = Attribute.where(user: self)
      #                                        .order('updated_at desc')
      #                                        .group([:entity_type, :entity_id])
      #                                        .limit(10)

      recently_changed_attributes = Attribute.where(user: self)
                                             .order('created_at desc')
                                             .limit(limit * 100)
                                             .group_by { |r| [r.entity_type, r.entity_id] }
                                             .keys
                                             .first(limit)

      @user_recent_content_list = recently_changed_attributes.map do |entity_type, entity_id|
        entity_type.constantize.find_by(id: entity_id)
      end.compact
    end
  end
end
