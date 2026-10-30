require 'test_helper'

# Blocks and follows belong to the person who made them, and only that person can undo them.
class UserRelationshipAccessTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user     = users(:one)
    @other    = users(:two)
    @stranger = User.create!(email: 'stranger@example.com', password: 'password', password_confirmation: 'password')
    UserBlocking.where(user: @user, blocked_user: @other).destroy_all
    UserFollowing.where(user: @user, followed_user: @other).destroy_all
    @block  = UserBlocking.create!(user: @user, blocked_user: @other)
    @follow = UserFollowing.create!(user: @user, followed_user: @other)
  end

  test "signed out visitors can't remove a block or a follow" do
    delete user_blocking_path(@block)
    assert_redirected_to new_user_session_path
    assert UserBlocking.exists?(@block.id)

    delete user_following_path(@follow)
    assert_redirected_to new_user_session_path
    assert UserFollowing.exists?(@follow.id)
  end

  test "the blocked user can't remove the block" do
    sign_in @other

    assert_raises(ActiveRecord::RecordNotFound) { delete user_blocking_path(@block) }
    assert UserBlocking.exists?(@block.id)
  end

  test "strangers can't remove someone else's block or follow" do
    sign_in @stranger

    assert_raises(ActiveRecord::RecordNotFound) { delete user_blocking_path(@block) }
    assert UserBlocking.exists?(@block.id)

    sign_in @stranger

    assert_raises(ActiveRecord::RecordNotFound) { delete user_following_path(@follow) }
    assert UserFollowing.exists?(@follow.id)
  end

  test "people can remove their own block and follow" do
    sign_in @user

    delete user_blocking_path(@block)
    assert_redirected_to @other
    assert_not UserBlocking.exists?(@block.id)

    delete user_following_path(@follow)
    assert_redirected_to @other
    assert_not UserFollowing.exists?(@follow.id)
  end

  test "signed in people can block and follow, as themselves" do
    sign_in @stranger

    post user_blockings_path, params: { user_blocking: { blocked_user_id: @other.id } }
    assert_redirected_to @other
    assert UserBlocking.exists?(user: @stranger, blocked_user: @other)

    post user_followings_path, params: { user_following: { followed_user_id: @user.id } }
    assert_redirected_to @user
    assert UserFollowing.exists?(user: @stranger, followed_user: @user)
  end

  test "the profile page's follow and block forms still work" do
    sign_in @stranger
    get user_path(@other)
    assert_response :success
    assert_select "form[action='#{user_followings_path}']"

    UserFollowing.create!(user: @stranger, followed_user: @other)
    sign_in @stranger
    get user_path(@other)
    assert_response :success
    assert_select "form[action='#{user_following_path(UserFollowing.find_by(user: @stranger, followed_user: @other))}']"
  end

  test "signed out visitors can't block or follow" do
    post user_blockings_path, params: { user_blocking: { blocked_user_id: @other.id } }
    assert_redirected_to new_user_session_path

    post user_followings_path, params: { user_following: { followed_user_id: @other.id } }
    assert_redirected_to new_user_session_path
  end

  test "the leftover block and follow pages are gone" do
    [
      -> { get user_blockings_path },
      -> { get new_user_blocking_path },
      -> { get user_blocking_path(@block) },
      -> { get edit_user_blocking_path(@block) },
      -> { patch user_blocking_path(@block), params: { user_blocking: { blocked_user_id: @user.id } } },
      -> { get user_followings_path },
      -> { get new_user_following_path },
      -> { get user_following_path(@follow) },
      -> { get edit_user_following_path(@follow) },
      -> { patch user_following_path(@follow), params: { user_following: { followed_user_id: @user.id } } }
    ].each do |request|
      assert_raises(ActionController::RoutingError, NameError) { request.call }
    end

    assert_equal @other.id, @block.reload.blocked_user_id
    assert_equal @other.id, @follow.reload.followed_user_id
  end
end
