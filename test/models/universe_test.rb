require 'test_helper'

class UniverseTest < ActiveSupport::TestCase
  test "Universe contributors can view/modify pages when private" do
    owner       = User.first
    contributor = User.last
    assert_not_equal(owner.id, contributor.id, "Test problem: Owner and contributor need different ideas!")

    universe = Universe.create!(name: "Test Universe", user: owner)
    universe.contributing_users << contributor
    assert universe.contributing_users.include?(contributor), "Contributor is a contributor"

    Rails.application.config.content_types[:all_non_universe].each do |page_type|
      page = page_type.new(user: owner, universe_id: universe.id, privacy: 'private')

      assert contributor.can_read?(page), "Contributor can view shared #{page_type.name}"
      assert contributor.can_update?(page), "Contributor can edit shared #{page_type.name}"

      assert owner.can_delete?(page), "Owner can delete their own shared #{page_type.name}"
      assert_not contributor.can_delete?(page), "Contributors cannot delete shared #{page_type.name}"
    end
  end

  test "Universe Premium is shared" do
    owner       = User.first
    owner.selected_billing_plan_id = BillingPlan::PREMIUM_IDS.first
    contributor = User.last
    contributor.selected_billing_plan_id = BillingPlan::FREE_IDS.first
    assert_not_equal(owner.id, contributor.id, "Test problem: Owner and contributor need different ideas!")

    Rails.application.config.content_types[:premium].each do |page_type|
      assert     owner.can_create?(page_type), "Owner can create #{page_type.name}"
      assert_not contributor.can_create?(page_type), "Contributor cannot create #{page_type.name}"
    end

    universe = Universe.create!(name: "Test Universe", user: owner)
    universe.contributing_users << contributor

    Rails.application.config.content_types[:all_non_universe].each do |page_type|
      page = page_type.new(universe_id: universe.id, user: contributor)

      assert page.creatable_by?(owner), "Owner can create #{page_type}"
      # assert page.creatable_by?(contributor), "Contributor can create #{page_type}"
    end
  end
end
