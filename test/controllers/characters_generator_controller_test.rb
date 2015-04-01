require 'test_helper'

# Tests for the CharactersGeneratorController
class CharactersGeneratorControllerTest < ActionController::TestCase
  test 'age' do
    assert_assigns :age, [:upper_limit, :lower_limit]
    assert_operator assigns(:lower_limit), :<=, assigns(:upper_limit)
  end

  test 'body type' do
    assert_assigns :bodytype, [:possible_types]
  end

  test 'eye color' do
    assert_assigns :eyecolor, [:possible_colors]
  end

  test 'facial hair' do
    assert_assigns :facialhair, [:possible_styles]
  end

  test 'hair color' do
    assert_assigns :haircolor, [:possible_colors]
  end

  test 'hair style' do
    assert_assigns :hairstyle, [:possible_styles]
  end

  test 'height' do
    assert_assigns :height, [
      :lower_foot_limit,
      :upper_foot_limit,
      :lower_inch_limit,
      :upper_inch_limit
    ]
    assert_operator assigns(:lower_foot_limit), :<=, assigns(:upper_foot_limit)
    assert_operator assigns(:lower_inch_limit), :<=, assigns(:upper_inch_limit)
  end

  test 'identifying mark' do
    assert_assigns :identifyingmark, [:possible_marks, :possible_locations]
  end

  test 'name' do
    assert_assigns :name, [
      :male_first_names,
      :female_first_names,
      :last_names,
      :all_first_names,
      :all_last_names
    ]
  end

  test 'race' do
    assert_assigns :race, [:possible_races]
  end

  test 'skin tone' do
    assert_assigns :skintone, [:possible_tones]
  end

  test 'weight' do
    assert_assigns :weight, [:upper_limit, :lower_limit]
    assert_operator assigns(:lower_limit), :<=, assigns(:upper_limit)
  end
end
