require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "User can create billing plan -specific pages" do
    free_user = User.new
    free_user.selected_billing_plan_id = 1

    premium_user = User.new
    premium_user.selected_billing_plan_id = BillingPlan::PREMIUM_IDS.first

    Rails.application.config.content_types[:free].each do |page_type|
      assert free_user.can_create?(page_type), "free user CAN create #{page_type.name}"
      assert premium_user.can_create?(page_type), "premium user CAN create #{page_type.name}"
    end

    Rails.application.config.content_types[:premium].each do |page_type|
      assert_not free_user.can_create?(page_type), "free user CANNOT create #{page_type.name}"
      assert     premium_user.can_create?(page_type), "premium user CAN create #{page_type.name}"
    end
  end

  test "User can view their own content regardless of plan" do
    user = User.new
    Rails.application.config.content_types[:all].each do |page_type|
      page = page_type.new(user: user)
      assert user.can_read?(page)
    end
  end

  test "User can edit their own content regardless of plan" do
    user = User.new
    Rails.application.config.content_types[:all].each do |page_type|
      page = page_type.new(user: user)
      assert user.can_update?(page)
    end
  end

  test "User can delete their own content" do
    user = User.new
    Rails.application.config.content_types[:all].each do |page_type|
      page = page_type.new(user: user)
      assert user.can_delete?(page)
    end
  end
end
