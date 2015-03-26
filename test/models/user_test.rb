require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'user not valid without a name' do
    user = users(:tolkien)
    user.name = nil

    refute user.valid?, 'Name is not being validated for presence'
  end

  test 'user not valid without a password' do
    user = users(:tolkien)
    user.password = nil

    refute user.valid?, 'Password is not being validated for presence'
  end

  test 'user not valid without an email address' do
    user = users(:tolkien)
    user.email = nil

    refute user.valid?, 'Email address is not being validated for presence'
  end

  test 'user fixture assumptions' do
    assert_not_nil users(:tolkien), 'User fixture :one is unavailable'
    assert users(:tolkien).valid?, 'User fixture :one is not a valid user'
  end

  test 'can get user content' do
    content = users(:tolkien).content

    assert_includes content[:characters], characters(:frodo), "User content doesn't include characters"
    assert_includes content[:equipment], equipment(:sting), "User content doesn't include equipment"
    assert_includes content[:languages], languages(:sindarin), "User content doesn't include languages"
    assert_includes content[:locations], locations(:shire), "User content doesn't include locations"
    assert_includes content[:magics], magics(:wizard), "User content doesn't include magics"
    assert_includes content[:universes], universes(:middleearth), "User content doesn't include universes"
  end

  test 'can count content' do
    assert_equal 6, users(:tolkien).content_count, "User didn't count its content properly"
  end
end
