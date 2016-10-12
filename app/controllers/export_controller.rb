class ExportController < ApplicationController

  def index
  end

  # Formats

  def universes_csv
    send_data to_csv(current_user.universes), filename: "universes-#{Date.today}.csv"
  end

  def characters_csv
    send_data to_csv(current_user.characters), filename: "characters-#{Date.today}.csv"
  end

  def locations_csv
    send_data to_csv(current_user.locations), filename: "locations-#{Date.today}.csv"
  end

  def items_csv
    send_data to_csv(current_user.items), filename: "items-#{Date.today}.csv"
  end

  def outline
    send_data content_to_outline, filename: "notebook-#{Date.today}.txt"
  end

  def notebook_json
    json_dump = current_user.content.map { |category, content| {"#{category}": fill_relations(content)} }.to_json
    send_data json_dump, filename: "notebook-#{Date.today}.json"
  end

  def notebook_xml
    xml_dump = current_user.content.map { |category, content| {"#{category}": fill_relations(content)}}.to_xml
    send_data xml_dump, filename: "notebook-#{Date.today}.xml"
  end

  def pdf
  end

  def html
  end

  def scrivener
  end

  private

  def to_csv ar_relation
    ar_class = ar_relation.build.class
    attributes = ar_class.attribute_categories.flat_map { |k, v| v[:attributes] }

    CSV.generate(headers: true) do |csv|
      csv << attributes

      ar_relation.each do |content|
        csv << attributes.map do |attr|
          value = content.send(attr)

          if value.is_a?(ActiveRecord::Associations::CollectionProxy)
            value = value.map(&:name).to_sentence
          elsif attr.end_with?('_id') && value.present?
            universe = Universe.where(id: value.to_i).first
            value = universe.name if universe
          end

          value
        end
      end
    end
  end

  def fill_relations ar_relation
    ar_class = ar_relation.build.class
    attributes = ar_class.attribute_categories.flat_map { |k, v| v[:attributes] }

    ar_relation.map do |content|
      content_repr = {}

      attributes.each do |attr|
        value = content.send(attr)
        next if value.nil? || value.blank?

        if value.is_a?(ActiveRecord::Associations::CollectionProxy)
          value = value.map(&:name).to_sentence
        elsif attr.end_with?('_id') && value.present?
          universe = Universe.where(id: value.to_i)
          value = universe.name if universe
        end

        content_repr[attr] = value
      end

      content_repr
    end
  end

  def content_to_outline
    content_types = %w(universes characters locations items)

    text = ""
    content_types.each do |content_type|
      ar_class = current_user.send(content_type).build.class
      attributes = ar_class.attribute_categories.flat_map { |k, v| v[:attributes] }

      text << "\n#{content_type.upcase}\n"
      current_user.send(content_type).each do |content|
        text << "  #{content.name}\n"

        attributes.each do |attr|
          value = content.send(attr)
          next if value.nil? || value.blank? || (value.respond_to?(:empty) && value.empty?)

          if value.is_a?(ActiveRecord::Associations::CollectionProxy)
            value = value.map(&:name).to_sentence
          elsif attr.end_with?('_id') && value.present?
            universe = Universe.where(id: value.to_i)
            value = universe.name if universe
          end

          text << "    #{attr}: #{value.split("\n").join("\n      ")}\n"
        end

        text << "\n"
      end
    end

    text
  end
end
