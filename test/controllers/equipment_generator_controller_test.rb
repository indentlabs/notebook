require 'test_helper'

# Tests for the EquipmentGeneratorController
class EquipmentGeneratorControllerTest < ActionController::TestCase
  test 'armor shield' do
    assert_assigns :armor_shield, [:shield_types]
  end

  test 'weapon' do
    assert_assigns :weapon, [:weapon_types]
  end

  test 'weapon axe' do
    assert_assigns :weapon_axe, [:axe_types]
  end

  test 'weapon bow' do
    assert_assigns :weapon_bow, [:bow_types]
  end

  test 'weapon club' do
    assert_assigns :weapon_club, [:club_types]
  end

  test 'weapon fist' do
    assert_assigns :weapon_fist, [:fist_weapon_types]
  end

  test 'weapon flexible' do
    assert_assigns :weapon_flexible, [:flexible_types]
  end

  test 'weapon thrown' do
    assert_assigns :weapon_thrown, [:thrown_types]
  end

  test 'weapon polearm' do
    assert_assigns :weapon_polearm, [:polearm_types]
  end

  test 'weapon shortsword' do
    assert_assigns :weapon_shortsword, [:shortsword_types]
  end

  test 'weapon sword' do
    assert_assigns :weapon_sword, [:sword_types]
  end
end
