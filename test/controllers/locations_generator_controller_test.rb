require 'test_helper'

# Tests for the LocationsGeneratorController
class LocationsGeneratorControllerTest < ActionController::TestCase
  test 'name' do
    assert_assigns :name, [
      :root_name,
      :prefix_occurrence,
      :postfix_occurrence,
      :syllables_upper_limit,
      :syllables_lower_limit,
      :prefixes,
      :postfixes,
      :syllables
    ]
    assert_operator assigns(:prefix_occurrence), :<=, 1
    assert_operator assigns(:prefix_occurrence), :>=, 0

    assert_operator assigns(:postfix_occurrence), :<=, 1
    assert_operator assigns(:postfix_occurrence), :>=, 0

    assert_operator(
      assigns(:syllables_lower_limit),
      :<=,
      assigns(:syllables_upper_limit))

    assert_operator assigns(:syllables_lower_limit), :>=, 0
  end
end
