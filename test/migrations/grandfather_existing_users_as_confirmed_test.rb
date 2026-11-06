require "test_helper"
require Rails.root.join("db/migrate/20261106120200_grandfather_existing_users_as_confirmed")

class GrandfatherExistingUsersAsConfirmedTest < ActiveSupport::TestCase
  test "every existing account, deleted ones included, is confirmed as of when it signed up" do
    signed_up_at = 3.years.ago.change(usec: 0)
    active  = User.create!(email: 'old-active@example.com', password: 'password')
    deleted = User.create!(email: 'old-deleted@example.com', password: 'password')
    active.update_columns(confirmed_at: nil, created_at: signed_up_at)
    deleted.update_columns(confirmed_at: nil, deleted_at: 1.day.ago)

    already_confirmed_at = 1.week.ago.change(usec: 0)
    users(:one).update_columns(confirmed_at: already_confirmed_at)

    GrandfatherExistingUsersAsConfirmed.new.tap { |m| m.verbose = false }.migrate(:up)

    assert_equal signed_up_at, active.reload.confirmed_at
    assert User.with_deleted.find(deleted.id).confirmed?
    assert_equal already_confirmed_at, users(:one).reload.confirmed_at, "already-confirmed accounts are untouched"
    assert_equal 0, User.with_deleted.where(confirmed_at: nil).count
  end
end
