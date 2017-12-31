class ExportController < ApplicationController
  before_action :authenticate_user!

  def index
    Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(current_user.id, 'viewed export page', {
      'content count': current_user.content_count
    }) if Rails.env.production?
  end

  def report_to_mixpanel format, scope
    Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(current_user.id, 'exported content', {
      'export format': format,
      'scope': scope
    }) if Rails.env.production?
  end

  # Formats

  def universes_csv
    report_to_mixpanel 'csv', 'universes'
    send_data to_csv(current_user.universes), filename: "universes-#{Date.today}.csv"
  end

  def characters_csv
    report_to_mixpanel 'csv', 'characters'
    send_data to_csv(current_user.characters), filename: "characters-#{Date.today}.csv"
  end

  def locations_csv
    report_to_mixpanel 'csv', 'locations'
    send_data to_csv(current_user.locations), filename: "locations-#{Date.today}.csv"
  end

  def items_csv
    report_to_mixpanel 'csv', 'items'
    send_data to_csv(current_user.items), filename: "items-#{Date.today}.csv"
  end

  def creatures_csv
    report_to_mixpanel 'csv', 'creatures'
    send_data to_csv(current_user.creatures), filename: "creatures-#{Date.today}.csv"
  end

  def races_csv
    report_to_mixpanel 'csv', 'races'
    send_data to_csv(current_user.races), filename: "races-#{Date.today}.csv"
  end

  def floras_csv
    report_to_mixpanel 'csv', 'flora'
    send_data to_csv(current_user.floras), filename: "floras-#{Date.today}.csv"
  end

  def religions_csv
    report_to_mixpanel 'csv', 'religions'
    send_data to_csv(current_user.religions), filename: "religions-#{Date.today}.csv"
  end

  def magics_csv
    report_to_mixpanel 'csv', 'magics'
    send_data to_csv(current_user.magics), filename: "magics-#{Date.today}.csv"
  end

  def languages_csv
    report_to_mixpanel 'csv', 'languages'
    send_data to_csv(current_user.languages), filename: "languages-#{Date.today}.csv"
  end

  def groups_csv
    report_to_mixpanel 'csv', 'groups'
    send_data to_csv(current_user.groups), filename: "groups-#{Date.today}.csv"
  end

  def towns_csv
    report_to_mixpanel 'csv', 'towns'
    send_data to_csv(current_user.towns), filename: "towns-#{Date.today}.csv"
  end

  def landmarks_csv
    report_to_mixpanel 'csv', 'landmarks'
    send_data to_csv(current_user.landmarks), filename: "landmarks-#{Date.today}.csv"
  end

  def countries_csv
    report_to_mixpanel 'csv', 'countries'
    send_data to_csv(current_user.countries), filename: "countries-#{Date.today}.csv"
  end

  def scenes_csv
    report_to_mixpanel 'csv', 'scenes'
    send_data to_csv(current_user.scenes), filename: "scenes-#{Date.today}.csv"
  end

  def outline
    report_to_mixpanel 'outline', 'notebook'
    send_data content_to_outline, filename: "notebook-#{Date.today}.txt"
  end

  def notebook_json
    report_to_mixpanel 'json', 'notebook'
    json_dump = current_user.content.map { |category, content| {"#{category}": fill_relations(content)} }.to_json
    send_data json_dump, filename: "notebook-#{Date.today}.json"
  end

  def notebook_xml
    report_to_mixpanel 'xml', 'notebook'
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
    attribute_categories = ar_class.attribute_categories(current_user)

    CSV.generate(headers: true) do |csv|
      csv << attribute_categories.flat_map(&:attribute_fields).map(&:label)

      ar_relation.each do |content|
        csv << attribute_categories.flat_map(&:attribute_fields).map do |attr|
          begin
            value = content.send(attr.name)
          rescue
            value = Attribute.where(user: current_user, attribute_field: attr, entity: content).first
            value = value.value if value
          end

          if value.is_a?(ActiveRecord::Associations::CollectionProxy)
            value = value.map(&:name).to_sentence
          elsif attr.name.end_with?('_id') && value.present?
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
    attribute_categories = ar_class.attribute_categories(current_user)

    ar_relation.map do |content|
      content_repr = {}

      attribute_categories.flat_map(&:attribute_fields).each do |attr|
        begin
          value = content.send(attr.name)
        rescue
          value = Attribute.where(user: current_user, attribute_field: attr, entity: content).first
          value = value.value if value
        end
        next if value.nil? || value.blank?

        if value.is_a?(ActiveRecord::Associations::CollectionProxy)
          value = value.map(&:name).to_sentence
        elsif attr.name.end_with?('_id') && value.present?
          universe = Universe.where(id: value.to_i)
          value = universe.name if universe
        end

        content_repr[attr.label] = value
      end

      content_repr
    end
  end

  def content_to_outline
    content_types = current_user.content.keys

    text = ""
    content_types.each do |content_type|
      ar_class = current_user.send(content_type).build.class
      attribute_categories = ar_class.attribute_categories(current_user)

      text << "\n#{content_type.upcase}\n"
      current_user.send(content_type).each do |content|
        text << "  #{content.name}\n"

        attribute_categories.flat_map(&:attribute_fields).each do |attr|
          begin
            value = content.send(attr.name)
          rescue
            value = Attribute.where(user: current_user, attribute_field: attr, entity: content).first
            value = value.value if value
          end
          next if value.nil? || value.blank? || (value.respond_to?(:empty) && value.empty?)

          if value.is_a?(ActiveRecord::Associations::CollectionProxy)
            value = value.map(&:name).to_sentence
          elsif attr.name.end_with?('_id') && value.present?
            universe = Universe.where(id: value.to_i).first
            value = universe.name if universe
          end

          text << "    #{attr.label}: #{value.to_s.split("\n").join("\n      ")}\n"
        end

        text << "\n"
      end
    end

    text
  end
end
