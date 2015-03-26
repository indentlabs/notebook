require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  test 'session not valid without a username' do
    session = sessions(:tolkien)
    session.username = nil

    refute session.valid?, 'Session username is not being validated for presence'
  end

  test 'session not valid without a password' do
    session = sessions(:tolkien)
    session.password = nil

    refute session.valid?, 'Session password is not being validated for presence'
  end

  test 'session fixture assumptions' do
    assert_not_nil sessions(:tolkien), 'Sessions fixture :one is not available'
    assert sessions(:tolkien).valid?, 'Sessions fixture :one is not a valid session'
  end
end
