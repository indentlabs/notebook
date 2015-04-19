require 'test_helper'

##
# Tests the entire ActiveModel::SecurePassword API implemented by the User model
#
# Taken from this demonstration:
# http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password
class UserSecurePasswordTest < ActiveSupport::TestCase
  setup do
    @username = 'ChrisTolkien'
    @email = 'chris@localhost'
    @rightpass = 'HiDad'
    @wrongpass = 'Mellon'
  end

  test 'cannot save user with mismatched password and confirmation' do
    user = User.new(name: @username,
                    password: @rightpass,
                    password_confirmation: @wrongpass)
    refute user.save,
           'Was able to save user despite mismatched password and confirmation'
  end

  test 'user with correct password and confirmation is a valid model' do
    user = User.new(name: @username,
                    email: @email,
                    password: @rightpass,
                    password_confirmation: @rightpass)
    assert user.valid?, "User model was not valid with a matching password
                         and confirmation: #{user.errors.messages}"
  end

  test 'can save user with matching password and confirmation' do
    user = User.new(name: @username,
                    email: @email,
                    password: @rightpass,
                    password_confirmation: @rightpass)

    assert user.save,
           'Wasn\'t able to save user despite matching password '\
           'and confirmation'
  end

  test 'can save a user with correct password and no confirmation' do
    user = User.new(name: @username,
                    email: @email,
                    password: @rightpass)

    assert user.save, 'Wasn\'t able to save user despite having a password'
  end

  test 'cannot authenticate a user with the incorrect password' do
    user = User.new(name: @username, password: @rightpass)

    refute user.authenticate(@wrongpass),
           'Was able to authenticate a user with an incorrect password'
  end

  test 'can authenticate a user with the correct password' do
    user = User.new(name: @username,
                    email: @email,
                    password: @rightpass)

    assert_not_nil user.authenticate(@rightpass),
                   'Was not able to authenticate a user with a correct password'
  end

  test 'can find a user and authenticate with the correct password' do
    User.create(name: @username,
                email: @email,
                password: @rightpass)

    assert_not_nil User.find_by(name: @username).try(:authenticate, @rightpass),
                   'Was not able to find & authenticate user with a '\
                   'correct password'
  end

  test 'cannot find and authenticate with an incorrect password' do
    User.create(name: @username,
                email: @email,
                password: @rightpass)

    refute User.find_by(name: @username).try(:authenticate, @wrongpass),
           'Was able to find & authenticate a user with an incorrect password'
  end
end
