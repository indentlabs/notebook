namespace :attributes do
  desc "Migrate linked fields to text fields with links for each user"
  task migrate_linked_fields: :environment do
    # For each content type
    Rails.application.config.content_types[:all].each do |content_type|
      require 'pry'

      puts content_type
      relation_fields = Rails.application.config.content_relations[content_type.name]
      next unless relation_fields
      relation_fields = relation_fields.values
      puts "Migrating #{content_type.name} (#{content_type.count}) / #{relation_fields.count} fields"

      # For each page
      content_type.find_each do |content_page|
        category_ids_for_this_pages_universe = if content_page.universe.present?
          content_page.universe.page_categories.pluck(:id)
        else
          PageCategory.where(content_type: content_type.name, universe_id: nil).pluck(:id)
        end

        # For each field
        relation_fields.each do |relation_field_data|
          relation_target_class = relation_field_data[:inverse_class]           # Character
          relation_accessor = relation_field_data[:through_relation].pluralize  # fathers
          puts "  relation = #{relation_accessor}"

          unless content_page.respond_to?(relation_accessor)
            puts "    Skipping!"
            next
          end

          # Create the field if it doesn't exist
          field_to_add_data_to = PageField.find_or_create_by(
            label: relation_accessor,
            page_category_id: category_ids_for_this_pages_universe
          )
          raise "No field associated with label=#{relation_accessor} / class=#{relation_target_class.name}" if field_to_add_data_to.nil?

          field_value = content_page.send(relation_accessor)

          binding.pry
          field_value.map! { |related_object|
            "[[#{related_object.class.name.downcase}-#{related_object.id}]]"
          }.join("\n") unless field_value.nil?

          field_to_add_data_to.page_field_values.find_or_create_by(
            value: field_value,
            page_id: content_page.id,
            user_id: content_page.user_id
          )
        end
      end
    end
  end
end
