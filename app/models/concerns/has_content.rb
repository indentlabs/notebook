require 'active_support/concern'

module HasContent
  extend ActiveSupport::Concern

  included do
    Rails.application.config.content_types[:all].each do |content_type|
      content_type_sym = content_type.name.downcase.pluralize.to_sym # :characters

      #has_many :characters, :locations, etc
      has_many content_type_sym, dependent: :destroy
    end
    has_many :timelines

    has_many :attribute_fields
    has_many :attribute_categories
    has_many :attribute_values, class_name: 'Attribute', dependent: :destroy

    def content_with_multiple_queries(
      content_types: Rails.application.config.content_type_names[:all],
      page_scoping:  { user_id: self.id },
      universe_id:   nil
    )
      @content_by_page_type = {}
      content_types.each do |content_type|
        type_specific_fields = ContentPage.polymorphic_content_fields
        type_specific_fields.push 'universe_id' unless content_type == 'Universe'

        pages_of_this_type = content_type.constantize
                                         .where(page_scoping)
                                         .select(type_specific_fields)

        if content_type != 'Universe' && universe_id.present?
          pages_of_this_type = pages_of_this_type.where(universe_id: universe_id)
        end

        @content_by_page_type[content_type] = []
        pages_of_this_type.each do |page_data|
          @content_by_page_type[content_type].push ContentPage.new(page_data.attributes)
        end
      end

      @content_by_page_type
    end

    # {
    #   characters: [...],
    #   locations:  [...]
    # }
    def content(
      content_types: Rails.application.config.content_type_names[:all],
      page_scoping:  { user_id: self.id },
      universe_id:   nil
    )
      return content_with_multiple_queries(content_types: content_types, page_scoping: page_scoping, universe_id: universe_id)

      return {} if content_types.empty?
      # TODO: we should return early if we already have @content_by_page_type!!!

      polymorphic_content_fields = ContentPage.polymorphic_content_fields
      where_conditions = page_scoping.map { |key, value| "#{key} = #{value}" }.join(' AND ') + ' AND deleted_at IS NULL AND archived_at IS NULL'

      sql = content_types.uniq.map do |page_type|
        if page_type != 'Universe'
          # Even though we're selecting universe_id here, it's still absent from all of the result rows. No idea why.
          # Removing Universe from `content_types` and adding universe_id to the content_fields works, so maybe it's something to
          # do with UNIONing the NULL column?
          # clause = "SELECT #{polymorphic_content_fields.join(',')},universe_id FROM #{page_type.downcase.pluralize} WHERE #{where_conditions}"
          clause = "SELECT #{polymorphic_content_fields.join(',')} FROM #{page_type.downcase.pluralize} WHERE #{where_conditions}"
        else
          # clause = "SELECT #{polymorphic_content_fields.join(',')},id          FROM #{page_type.downcase.pluralize} WHERE #{where_conditions}"
          clause = "SELECT #{polymorphic_content_fields.join(',')} FROM #{page_type.downcase.pluralize} WHERE #{where_conditions}"
        end

        if universe_id.present? && page_type != 'Universe'
          clause += " AND universe_id = #{universe_id}"
        end
        clause
      end.compact.join(' UNION ALL ') + ' ORDER BY page_type, id'

      # TODO: improve this query -- it uses a tooon of memory
      result = ActiveRecord::Base.connection.execute(sql)
      @content_by_page_type ||= result.to_a.each_with_object({}) do |object, hash|
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
      polymorphic_content_fields = ContentPage.polymorphic_content_fields
      where_conditions = page_scoping.map { |key, value| "#{key} = #{value}" }.join(' AND ') + ' AND deleted_at IS NULL AND archived_at IS NULL'

      sql = content_types.uniq.map do |page_type|
        "SELECT #{polymorphic_content_fields.join(',')} FROM #{page_type.downcase.pluralize} WHERE #{where_conditions}"
      end.join(' UNION ALL ')

      # TODO: improve this query -- it uses a tooon of memory
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
      @user_recent_content_list ||= content_list
        .sort_by { |page| page['updated_at'] }
        .reverse
        .first(limit)
        .map { |page_data| ContentPage.new(page_data) }
    end
  end
end
