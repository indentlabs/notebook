require 'csv'

# Imports a template structure (categories + fields) exported by TemplateExportService
# back onto a user's content type.
#
# Two modes are supported:
#
#   :merge   - additive. Categories and fields present in the file are created if
#              missing and updated if they already exist. Nothing is ever removed.
#   :replace - sync. Same as :merge, but categories and fields that the user has
#              which are *not* in the file are deleted afterwards, so the template
#              ends up matching the file exactly. System fields (name / universe /
#              tags) are never removed.
#
# Both modes are safe to `analyze` first: the analysis reports exactly what would
# be created, updated and removed, including how many written answers would be
# destroyed.
class TemplateImportService
  class InvalidTemplateError < StandardError; end

  SUPPORTED_FORMATS  = %w[yml yaml json csv].freeze
  MAX_CONTENT_LENGTH = 2.megabytes
  MAX_CATEGORIES     = 200
  MAX_FIELDS         = 2_000

  # Field types the editor knows how to render.
  KNOWN_FIELD_TYPES = %w[text_area link name universe tags].freeze
  # Field types a user can't create or delete by hand; they're managed by the app.
  SYSTEM_FIELD_TYPES = AttributeField::UNDELETEABLE_FIELD_TYPES

  MODES = %w[merge replace].freeze

  def initialize(user, content_type, raw_content, filename: nil, format: nil)
    @user               = user
    @content_type       = content_type.to_s.downcase
    @content_type_class = @content_type.titleize.constantize
    @raw_content        = raw_content.to_s
    @format             = (format.presence || format_from_filename(filename)).to_s.downcase.delete_prefix('.')
  end

  # Returns a preview of what an import would do, without touching the database.
  def analyze(mode: 'merge')
    plan = build_plan(normalize_mode(mode))

    {
      success: true,
      mode: plan[:mode],
      format: @format,
      content_type: @content_type,
      source_content_type: plan[:source_content_type],
      categories_to_create: plan[:categories_to_create].map { |c| c[:label] },
      categories_to_update: plan[:categories_to_update].map { |c| c[:label] },
      categories_to_remove: plan[:categories_to_remove].map { |c| c[:label] },
      fields_to_create: plan[:fields_to_create].map { |f| { category: f[:category_label], field: f[:label] } },
      fields_to_update: plan[:fields_to_update].map { |f| { category: f[:category_label], field: f[:label] } },
      fields_to_remove: plan[:fields_to_remove].map do |f|
        { category: f[:category_label], field: f[:label], filled_count: f[:filled_count] }
      end,
      counts: {
        categories_created: plan[:categories_to_create].size,
        categories_updated: plan[:categories_to_update].size,
        categories_removed: plan[:categories_to_remove].size,
        fields_created: plan[:fields_to_create].size,
        fields_updated: plan[:fields_to_update].size,
        fields_removed: plan[:fields_to_remove].size
      },
      filled_answers_at_risk: plan[:filled_answers_at_risk],
      affected_pages_count: plan[:affected_pages_count],
      warnings: plan[:warnings]
    }
  rescue InvalidTemplateError => e
    { success: false, error: e.message }
  end

  # Applies the import. Returns a summary hash with :success.
  def import!(mode: 'merge')
    plan = build_plan(normalize_mode(mode))

    created_categories = 0
    updated_categories = 0
    removed_categories = 0
    created_fields     = 0
    updated_fields     = 0
    removed_fields     = 0

    ActiveRecord::Base.transaction do
      plan[:categories].each do |entry|
        category = entry[:record] || create_category(entry)
        if entry[:record]
          updated_categories += 1 if apply_category_attributes(category, entry)
        else
          created_categories += 1
        end

        entry[:fields].each do |field_entry|
          if field_entry[:record]
            updated_fields += 1 if apply_field_attributes(field_entry[:record], field_entry)
          else
            create_field(category, field_entry)
            created_fields += 1
          end
        end
      end

      plan[:fields_to_remove].each do |field_entry|
        field_entry[:record].destroy
        removed_fields += 1
      end

      plan[:categories_to_remove].each do |category_entry|
        category_entry[:record].destroy
        removed_categories += 1
      end
    end

    @content_type_class.clear_attribute_cache(@user) if @content_type_class.respond_to?(:clear_attribute_cache)
    Rails.cache.delete("#{@content_type}_template_#{@user.id}")

    {
      success: true,
      mode: plan[:mode],
      created_categories: created_categories,
      updated_categories: updated_categories,
      removed_categories: removed_categories,
      created_fields: created_fields,
      updated_fields: updated_fields,
      removed_fields: removed_fields,
      warnings: plan[:warnings],
      message: import_summary_message(
        created_categories: created_categories, updated_categories: updated_categories,
        removed_categories: removed_categories, created_fields: created_fields,
        updated_fields: updated_fields, removed_fields: removed_fields
      )
    }
  rescue InvalidTemplateError => e
    { success: false, error: e.message }
  rescue => e
    Rails.logger.error "Template import failed for user #{@user.id}, content_type #{@content_type}: #{e.message}"
    { success: false, error: "Import failed: #{e.message}" }
  end

  private

  def normalize_mode(mode)
    mode = mode.to_s.presence || 'merge'
    raise InvalidTemplateError, "Unknown import mode: #{mode}" unless MODES.include?(mode)

    mode
  end

  def format_from_filename(filename)
    return '' if filename.blank?

    File.extname(filename.to_s)
  end

  # ---------------------------------------------------------------------------
  # Parsing
  # ---------------------------------------------------------------------------

  # Normalized shape:
  #   { content_type: 'character',
  #     categories: [ { name:, label:, icon:, description:, hidden:, fields: [
  #                     { name:, label:, field_type:, description:, hidden:, field_options: } ] } ] }
  def parsed_template
    @parsed_template ||= begin
      raise InvalidTemplateError, 'No template file was uploaded.' if @raw_content.blank?

      if @raw_content.bytesize > MAX_CONTENT_LENGTH
        raise InvalidTemplateError, "Template file is too large (max #{MAX_CONTENT_LENGTH / 1.megabyte}MB)."
      end

      unless SUPPORTED_FORMATS.include?(@format)
        raise InvalidTemplateError,
              "Unsupported file type#{" '#{@format}'" if @format.present?}. Upload a .yml, .json, or .csv template export."
      end

      template = case @format
                 when 'yml', 'yaml' then parse_structured(parse_yaml)
                 when 'json'        then parse_structured(parse_json)
                 when 'csv'         then parse_csv
                 end

      if template[:categories].blank?
        raise InvalidTemplateError, "That file doesn't contain any template categories."
      end

      if template[:categories].size > MAX_CATEGORIES
        raise InvalidTemplateError, "That template has too many categories (max #{MAX_CATEGORIES})."
      end

      if template[:categories].sum { |c| c[:fields].size } > MAX_FIELDS
        raise InvalidTemplateError, "That template has too many fields (max #{MAX_FIELDS})."
      end

      template
    end
  end

  def parse_yaml
    YAML.safe_load(@raw_content, permitted_classes: [Symbol], aliases: true)
  rescue Psych::Exception => e
    raise InvalidTemplateError, "That file isn't valid YAML (#{e.message.truncate(120)})."
  end

  def parse_json
    JSON.parse(@raw_content)
  rescue JSON::ParserError => e
    raise InvalidTemplateError, "That file isn't valid JSON (#{e.message.truncate(120)})."
  end

  # Handles both a full export (`{ template: { categories: {...} } }`) and a bare
  # `{ categories: {...} }` / `{ overview: {...} }` structure.
  def parse_structured(data)
    raise InvalidTemplateError, "That file doesn't look like a template export." unless data.is_a?(Hash)

    data = data.deep_symbolize_keys
    root = data[:template].is_a?(Hash) ? data[:template] : data
    categories = root[:categories].presence || root

    unless categories.is_a?(Hash) || categories.is_a?(Array)
      raise InvalidTemplateError, "That file doesn't contain a recognizable list of categories."
    end

    {
      content_type: root[:content_type].presence&.to_s&.downcase,
      categories: normalize_category_collection(categories)
    }
  end

  def normalize_category_collection(categories)
    entries = categories.is_a?(Hash) ? categories.map { |key, value| [key, value] } : categories.map { |v| [nil, v] }

    entries.filter_map do |key, value|
      next unless value.is_a?(Hash)

      value = value.deep_symbolize_keys
      label = value[:label].presence || key.to_s.titleize
      next if label.blank?

      {
        name: (value[:name].presence || key).to_s.presence,
        label: label.to_s.truncate(255),
        icon: value[:icon].presence&.to_s,
        description: value[:description].presence&.to_s,
        hidden: truthy?(value[:hidden]),
        fields: normalize_field_collection(value[:fields] || value[:attributes])
      }
    end
  end

  def normalize_field_collection(fields)
    return [] if fields.blank?

    entries = fields.is_a?(Hash) ? fields.map { |key, value| [key, value] } : fields.map { |v| [nil, v] }

    entries.filter_map do |key, value|
      next unless value.is_a?(Hash)

      value = value.deep_symbolize_keys
      label = value[:label].presence || key.to_s.titleize
      next if label.blank?

      {
        name: (value[:name].presence || key).to_s.presence,
        label: label.to_s.truncate(255),
        field_type: coerce_field_type(value[:field_type]),
        description: value[:description].presence&.to_s,
        hidden: truthy?(value[:hidden]),
        field_options: normalize_field_options(value[:field_options])
      }
    end
  end

  def parse_csv
    rows = CSV.parse(@raw_content, headers: true)
    raise InvalidTemplateError, 'That CSV file has no rows.' if rows.headers.blank?

    unless rows.headers.include?('Category')
      raise InvalidTemplateError, "That CSV is missing a 'Category' column. Export a template as CSV to see the expected columns."
    end

    categories = {}
    rows.each do |row|
      category_label = row['Category'].to_s.strip
      next if category_label.blank?

      category = categories[category_label] ||= {
        name: nil,
        label: category_label.truncate(255),
        icon: nil,
        description: row['Category_Description'].presence,
        hidden: truthy?(row['Category_Hidden']),
        fields: []
      }

      field_label = row['Field'].to_s.strip
      next if field_label.blank?

      category[:fields] << {
        name: nil,
        label: field_label.truncate(255),
        field_type: coerce_field_type(row['Field_Type']),
        description: row['Field_Description'].presence,
        hidden: truthy?(row['Field_Hidden']),
        field_options: normalize_field_options(parse_csv_field_options(row['Field_Options']))
      }
    end

    { content_type: nil, categories: categories.values }
  rescue CSV::MalformedCSVError => e
    raise InvalidTemplateError, "That file isn't valid CSV (#{e.message.truncate(120)})."
  end

  def parse_csv_field_options(raw)
    return {} if raw.blank?

    JSON.parse(raw)
  rescue JSON::ParserError
    {}
  end

  def coerce_field_type(raw)
    type = raw.to_s.strip.downcase
    type = 'text_area' if type.blank?
    type = 'text_area' if type == 'textarea'
    KNOWN_FIELD_TYPES.include?(type) ? type : 'text_area'
  end

  def normalize_field_options(options)
    return {} unless options.is_a?(Hash)

    options = options.deep_symbolize_keys
    cleaned = {}

    if options[:linkable_types].present?
      valid_types = Rails.application.config.content_types[:all].map(&:name)
      linkable = Array(options[:linkable_types]).map(&:to_s).select { |t| valid_types.include?(t) }
      cleaned['linkable_types'] = linkable if linkable.any?
    end

    cleaned['display_style'] = options[:display_style].to_s if options[:display_style].present?
    cleaned['input_size']    = options[:input_size].to_s if options[:input_size].present?
    cleaned
  end

  def truthy?(value)
    ActiveModel::Type::Boolean.new.cast(value) || false
  end

  # ---------------------------------------------------------------------------
  # Planning
  # ---------------------------------------------------------------------------

  def build_plan(mode)
    template = parsed_template
    warnings = []

    if template[:content_type].present? && template[:content_type] != @content_type
      warnings << "This file was exported from a #{template[:content_type].titleize} template. " \
                  "Importing it here will add those categories and fields to your #{@content_type.titleize} pages."
    end

    # Scoped the same way the template editor is: Settings / Contributors /
    # Gallery / Changelog are app-managed, never exported, and must never be
    # touched by an import.
    existing_categories = @user.attribute_categories
                               .where(entity_type: @content_type)
                               .shown_on_template_editor
                               .includes(:attribute_fields)
                               .to_a

    imported_categories = template[:categories].reject do |category|
      AttributeCategory::SPECIAL_CATEGORY_LABELS.any? { |label| label.casecmp?(category[:label]) }
    end

    skipped = template[:categories].size - imported_categories.size
    if skipped.positive?
      warnings << "Skipped #{skipped} #{'category'.pluralize(skipped)} named after a built-in section " \
                  "(#{AttributeCategory::SPECIAL_CATEGORY_LABELS.to_sentence}). Those are managed by Notebook.ai."
    end

    matched_category_ids = []
    matched_field_ids    = []

    categories_to_create = []
    categories_to_update = []
    fields_to_create     = []
    fields_to_update     = []

    planned_categories = imported_categories.map do |imported_category|
      existing = find_existing_category(existing_categories, imported_category, matched_category_ids)
      matched_category_ids << existing.id if existing

      existing_fields = existing ? existing.attribute_fields.to_a : []

      planned_fields = imported_category[:fields].map do |imported_field|
        existing_field = find_existing_field(existing_fields, imported_field, matched_field_ids)
        matched_field_ids << existing_field.id if existing_field

        entry = imported_field.merge(
          record: existing_field,
          category_label: imported_category[:label]
        )

        if existing_field
          fields_to_update << entry if field_changes(existing_field, entry).any?
        else
          fields_to_create << entry
        end

        entry
      end

      entry = imported_category.merge(record: existing, fields: planned_fields)

      if existing
        categories_to_update << entry if category_changes(existing, entry).any?
      else
        categories_to_create << entry
      end

      entry
    end

    fields_to_remove     = []
    categories_to_remove = []

    if mode == 'replace'
      existing_categories.each do |category|
        category_matched = matched_category_ids.include?(category.id)

        category.attribute_fields.each do |field|
          next if matched_field_ids.include?(field.id)
          next if SYSTEM_FIELD_TYPES.include?(field.field_type)

          fields_to_remove << {
            record: field,
            category_label: category.label,
            label: field.label,
            filled_count: filled_answer_count(field)
          }
        end

        next if category_matched

        # Only drop a whole category once every field in it is going away.
        surviving = category.attribute_fields.reject do |field|
          fields_to_remove.any? { |entry| entry[:record].id == field.id }
        end
        next if surviving.any?

        categories_to_remove << { record: category, label: category.label }
      end
    end

    affected_pages = Set.new
    fields_to_remove.each do |entry|
      entry[:record].attribute_values.where.not(value: [nil, '']).pluck(:entity_type, :entity_id).each do |type, id|
        affected_pages.add("#{type}:#{id}")
      end
    end

    if mode == 'replace' && fields_to_remove.any?
      warnings << "Replace mode removes #{fields_to_remove.size} #{'field'.pluralize(fields_to_remove.size)} " \
                  'that are not in this file. Name, universe and tag fields are always kept.'
    end

    {
      mode: mode,
      source_content_type: template[:content_type],
      categories: planned_categories,
      categories_to_create: categories_to_create,
      categories_to_update: categories_to_update,
      categories_to_remove: categories_to_remove,
      fields_to_create: fields_to_create,
      fields_to_update: fields_to_update,
      fields_to_remove: fields_to_remove,
      filled_answers_at_risk: fields_to_remove.sum { |entry| entry[:filled_count] },
      affected_pages_count: affected_pages.size,
      warnings: warnings
    }
  end

  def filled_answer_count(field)
    field.attribute_values.where.not(value: [nil, '']).count
  end

  def find_existing_category(existing_categories, imported, already_matched)
    candidates = existing_categories.reject { |c| already_matched.include?(c.id) }

    if imported[:name].present?
      match = candidates.find { |c| c.name.to_s.casecmp?(imported[:name]) }
      return match if match
    end

    candidates.find { |c| c.label.to_s.casecmp?(imported[:label]) }
  end

  def find_existing_field(existing_fields, imported, already_matched)
    candidates = existing_fields.reject { |f| already_matched.include?(f.id) }

    if imported[:name].present?
      match = candidates.find do |f|
        f.name.to_s.casecmp?(imported[:name]) || f.old_column_source.to_s.casecmp?(imported[:name])
      end
      return match if match
    end

    candidates.find { |f| f.label.to_s.casecmp?(imported[:label]) }
  end

  # ---------------------------------------------------------------------------
  # Applying
  # ---------------------------------------------------------------------------

  def category_changes(category, entry)
    changes = {}
    changes[:label]       = entry[:label] if entry[:label].present? && category.label != entry[:label]
    changes[:icon]        = entry[:icon] if entry[:icon].present? && category[:icon] != entry[:icon]
    changes[:description] = entry[:description] if entry[:description].present? && category.description != entry[:description]
    changes[:hidden]      = entry[:hidden] if category.hidden? != entry[:hidden]
    changes
  end

  def field_changes(field, entry)
    changes = {}
    changes[:label]       = entry[:label] if entry[:label].present? && field.label != entry[:label]
    changes[:description] = entry[:description] if entry[:description].present? && field.description != entry[:description]
    changes[:hidden]      = entry[:hidden] if field.hidden? != entry[:hidden]

    # Never rewrite the type of a system field, and don't silently convert a
    # user's existing field into something else.
    if entry[:field_options].present? && (field.field_options || {}).stringify_keys != entry[:field_options]
      changes[:field_options] = entry[:field_options] if field.field_type == 'link'
    end

    changes
  end

  def apply_category_attributes(category, entry)
    changes = category_changes(category, entry)
    return false if changes.empty?

    category.update!(changes)
    true
  end

  def apply_field_attributes(field, entry)
    changes = field_changes(field, entry)
    return false if changes.empty?

    field.update!(changes.merge(migrated_from_legacy: true))
    true
  end

  def create_category(entry)
    @user.attribute_categories.create!(
      entity_type: @content_type,
      name: unique_category_name(entry),
      label: entry[:label],
      icon: entry[:icon].presence || 'help',
      description: entry[:description],
      hidden: entry[:hidden]
    )
  end

  def create_field(category, entry)
    # Only one name / universe / tags field can meaningfully exist per template,
    # and they're created by the app itself. Import them as plain text fields
    # rather than duplicating the app-managed ones.
    field_type = entry[:field_type]
    field_type = 'text_area' if SYSTEM_FIELD_TYPES.include?(field_type) &&
                                category.attribute_fields.exists?(field_type: field_type)

    category.attribute_fields.create!(
      user: @user,
      name: unique_field_name(category, entry),
      label: entry[:label],
      field_type: field_type,
      description: entry[:description],
      hidden: entry[:hidden],
      field_options: entry[:field_options],
      migrated_from_legacy: true
    )
  end

  def unique_category_name(entry)
    base = (entry[:name].presence || entry[:label]).to_s.parameterize(separator: '_')
    base = "category_#{Time.now.to_i}" if base.blank?
    return base unless @user.attribute_categories.exists?(entity_type: @content_type, name: base)

    "#{base}_#{SecureRandom.hex(3)}"
  end

  def unique_field_name(category, entry)
    base = (entry[:name].presence || entry[:label]).to_s.parameterize(separator: '_')
    base = "field_#{Time.now.to_i}" if base.blank?
    return base unless category.attribute_fields.exists?(name: base)

    "#{base}_#{SecureRandom.hex(3)}"
  end

  def import_summary_message(counts)
    parts = []
    parts << "#{counts[:created_categories]} #{'category'.pluralize(counts[:created_categories])} added" if counts[:created_categories].positive?
    parts << "#{counts[:created_fields]} #{'field'.pluralize(counts[:created_fields])} added" if counts[:created_fields].positive?
    parts << "#{counts[:updated_categories]} #{'category'.pluralize(counts[:updated_categories])} updated" if counts[:updated_categories].positive?
    parts << "#{counts[:updated_fields]} #{'field'.pluralize(counts[:updated_fields])} updated" if counts[:updated_fields].positive?
    parts << "#{counts[:removed_fields]} #{'field'.pluralize(counts[:removed_fields])} removed" if counts[:removed_fields].positive?
    parts << "#{counts[:removed_categories]} #{'category'.pluralize(counts[:removed_categories])} removed" if counts[:removed_categories].positive?

    return 'Template imported — everything in that file already matched your template.' if parts.empty?

    "Template imported! #{parts.to_sentence.upcase_first}."
  end
end
