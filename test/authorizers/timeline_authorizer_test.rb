require 'test_helper'

class TimelineAuthorizerTest < ActiveSupport::TestCase
  setup do
    @author   = User.first
    @stranger = User.last
    assert_not_equal(@author.id, @stranger.id, "Test problem: author and stranger need to be different users")
  end

  def anonymous
    User.new
  end

  test "an unclaimed contributor invite doesn't open a private timeline to anonymous viewers" do
    universe = Universe.create!(user: @author, name: 'Private Universe', privacy: 'private')
    Contributor.create!(universe: universe, email: 'invited@example.com')
    timeline = Timeline.create!(user: @author, name: 'My Timeline', privacy: 'private', universe: universe)

    assert_not anonymous.can_read?(timeline)
    assert_not anonymous.can_update?(timeline)
    assert_not @stranger.can_read?(timeline)
  end

  test "a claimed contributor invite still gives access" do
    universe = Universe.create!(user: @author, name: 'Private Universe', privacy: 'private')
    Contributor.create!(universe: universe, user: @stranger, email: @stranger.email)
    timeline = Timeline.create!(user: @author, name: 'My Timeline', privacy: 'private', universe: universe)

    assert @stranger.can_read?(timeline)
    assert @stranger.can_update?(timeline)
    assert_not @stranger.can_delete?(timeline)
  end
end
