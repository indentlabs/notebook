require 'test_helper'

class ContentPageTest < ActiveSupport::TestCase
  test "Content pages require a user to create" do
    Rails.application.config.content_types[:all].each do |page_type|
      assert_raises(ActiveRecord::RecordInvalid) do
        page_type.create!
      end
    end
  end

  test "Content page privacy levels" do
    user = User.first
    Rails.application.config.content_types[:all].each do |page_type|
      page = page_type.new(user: user, privacy: 'private')

      assert user.can_read?(page)
      assert_not User.new.can_read?(page)
      # TODO collaborators

      assert user.can_update?(page)
      assert_not User.new.can_update?(page)
      # TODO collaborators
    end
  end
end
