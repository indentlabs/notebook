require 'test_helper'

# Tests for the SessionsController class
class SessionsControllerTest < ActionController::TestCase
  test 'old password migrates to bcrypt' do
    post :create, session: {
      username: users(:martin).name,
      password: 'HODOR'
    }

    migrated_martin = User.find_by(name: users(:martin).name)
                      .authenticate('HODOR')

    assert_not_nil migrated_martin,
                   'Could not authenticate an older user using the '\
                   'new bcrypt scheme'
  end

  test 'old password is cleared when user is migrated' do
    post :create, session: {
      username: users(:martin).name,
      password: 'HODOR'
    }

    old_password = User.find_by(name: users(:martin).name).old_password

    assert old_password.blank?
  end
end
