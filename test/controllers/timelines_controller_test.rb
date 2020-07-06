require 'test_helper'

class TimelinesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @timeline = timelines(:one)
  end

  test "should get index" do
    get timelines_url
    assert_response :success
  end

  test "should get new" do
    get new_timeline_url
    assert_response :success
  end

  test "should create timeline" do
    assert_difference('Timeline.count') do
      post timelines_url, params: { timeline: {  } }
    end

    assert_redirected_to timeline_url(Timeline.last)
  end

  test "should show timeline" do
    get timeline_url(@timeline)
    assert_response :success
  end

  test "should get edit" do
    get edit_timeline_url(@timeline)
    assert_response :success
  end

  test "should update timeline" do
    patch timeline_url(@timeline), params: { timeline: {  } }
    assert_redirected_to timeline_url(@timeline)
  end

  test "should destroy timeline" do
    assert_difference('Timeline.count', -1) do
      delete timeline_url(@timeline)
    end

    assert_redirected_to timelines_url
  end
end
