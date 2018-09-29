class LanguagesController < ContentController
  private

  def content_param_list
    %i(
      name other_names universe_id
      history typology dialectical_information register
      phonology
      grammar
      numbers quantifiers
      notes private_notes privacy
    ) + [
      custom_attribute_values:     [:name, :value]
    ]
  end
end
