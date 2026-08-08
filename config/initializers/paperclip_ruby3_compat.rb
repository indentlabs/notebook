# Paperclip 6.1.0 is unmaintained and predates Ruby 3's separation of positional
# and keyword arguments. Its validators build an options Hash and pass it as a
# third *positional* argument to ActiveModel::Errors#add:
#
#   record.errors.add attribute, :invalid, options.merge(:types => types.join(', '))
#
# Rails 6.1 defines `add(attribute, type = :invalid, **options)`, so under Ruby 3
# that Hash is no longer auto-converted to keyword arguments and every attempt to
# record a validation failure raises:
#
#   ArgumentError: wrong number of arguments (given 3, expected 1..2)
#
# In practice that turned "user uploaded a file we don't accept" into an
# unhandled 500 on every content page update carrying an image.
#
# These patches re-issue the same calls with a double splat. Delete them along
# with paperclip once ImageUpload has finished migrating to ActiveStorage.

Paperclip::Validators::AttachmentContentTypeValidator.class_eval do
  def mark_invalid(record, attribute, types)
    record.errors.add attribute, :invalid, **options.symbolize_keys.merge(types: types.join(', '))
  end
end

Paperclip::Validators::AttachmentFileNameValidator.class_eval do
  def mark_invalid(record, attribute, patterns)
    record.errors.add attribute, :invalid, **options.symbolize_keys.merge(names: patterns.join(', '))
  end
end

Paperclip::Validators::AttachmentPresenceValidator.class_eval do
  def validate_each(record, attribute, value)
    if record.send("#{attribute}_file_name").blank?
      record.errors.add(attribute, :blank, **options.symbolize_keys)
    end
  end
end

Paperclip::Validators::AttachmentSizeValidator.class_eval do
  def validate_each(record, attr_name, value)
    base_attr_name = attr_name
    attr_name = "#{attr_name}_file_size".to_sym
    value = record.send(:read_attribute_for_validation, attr_name)

    return if value.blank?

    options.slice(*self.class::AVAILABLE_CHECKS).each do |option, option_value|
      option_value = option_value.call(record) if option_value.is_a?(Proc)
      option_value = extract_option_value(option, option_value)

      next if value.send(self.class::CHECKS[option], option_value)

      error_message_key = options[:in] ? :in_between : option
      [attr_name, base_attr_name].each do |error_attr_name|
        record.errors.add(error_attr_name, error_message_key, **filtered_options(value).symbolize_keys.merge(
          min: min_value_in_human_size(record),
          max: max_value_in_human_size(record),
          count: human_size(option_value)
        ))
      end
    end
  end
end
