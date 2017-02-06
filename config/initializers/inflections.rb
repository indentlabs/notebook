# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
ActiveSupport::Inflector.inflections do |inflect|
  #todo: Not sure how this interacts with translation files; might just be
  #      that we need pluralizations per-language that need them
  #todo: Also, this doesn't seem to work since it also applies to the table name we look at (which is magics).
  #inflect.plural /^(magic)$/i, 'types of \1' # Pluralize "magic" to "types of magic"

  # inflect.plural /^(ox)$/i, '\1en'
  # inflect.singular /^(ox)en/i, '\1'
  # inflect.irregular 'person', 'people'
  # inflect.uncountable %w( fish sheep )
end
#
# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections do |inflect|
#   inflect.acronym 'RESTful'
# end
