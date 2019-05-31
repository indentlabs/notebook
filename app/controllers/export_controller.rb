class ExportController < ApplicationController
  before_action :authenticate_user!
  before_action :whitelist_pluralized_model, only: [:csv]

  def index
    @sidenav_expansion = 'my account'

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

  def csv # params[:model] needed
    report_to_mixpanel 'csv', @pluralized_model
    send_data to_csv(current_user.send(@pluralized_model)), filename: "#{@pluralized_model}-#{Date.today}.csv"
  end

  def outline
    report_to_mixpanel 'outline', 'notebook'
    send_data content_to_outline, filename: "notebook-#{Date.today}.txt"
  end

  def notebook_json
    report_to_mixpanel 'json', 'notebook'
    json_dump = current_user.content.except('Document').map { |category, content| {"#{category}": fill_relations(category.constantize, content)} }.to_json
    send_data json_dump, filename: "notebook-#{Date.today}.json"
  end

  def notebook_xml
    report_to_mixpanel 'xml', 'notebook'
    xml_dump = current_user.content.except('Document').map { |category, content| {"#{category}": fill_relations(category.constantize, content)}}.to_xml
    send_data xml_dump, filename: "notebook-#{Date.today}.xml"
  end

  def pdf
    #todo
  end

  def html
    #todo
  end

  def scrivener
    #todo
  end

  private

  def whitelist_pluralized_model
    @pluralized_model = params[:model]
    valid_models_to_export = Rails.application.config.content_types[:all].map { |p| p.name.downcase.pluralize }

    unless valid_models_to_export.include?(@pluralized_model)
      redirect_to root_path, notice: "You don't have permission to do that!"
      return false
    end
  end

  def to_csv ar_relation
    # todo change this and (ALL `.build.class` to `.klass`)
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

  def fill_relations(ar_class, ar_relation)
    attribute_categories = ar_class.attribute_categories(current_user)

    ar_relation.map do |content|
      content_repr = {}

      attribute_categories.flat_map(&:attribute_fields).each do |attr|
        begin
          value = content.send(attr.name)
        rescue
          value = Attribute.find_by(user: current_user, attribute_field: attr, entity_id: content.id, entity_type: ar_class.name)
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
    content_types = current_user.content.except('Document').keys

    text = ""
    content_types.each do |content_type|
      ar_class = content_type.constantize
      attribute_categories = ar_class.attribute_categories(current_user)

      text << "\n#{content_type.upcase}\n"
      current_user.send(content_type.downcase.pluralize).each do |content|
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
