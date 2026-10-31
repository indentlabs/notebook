require 'test_helper'
require 'minitest/mock'

# will_paginate and Kaminari both define `.page` on ActiveRecord. RailsAdmin
# paginates its list pages with Kaminari, so if will_paginate's `.page` wins,
# every list page 500s with "undefined method `per'" -- including the page
# RailsAdmin redirects to after deleting a record.
class RailsAdminPaginationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:one)
    @admin.update_columns(site_administrator: true)
    sign_in @admin
  end

  test "kaminari and will_paginate pagination both work on models" do
    assert_respond_to User.all.send(Kaminari.config.page_method_name, 1), :per
    assert_respond_to User.paginate(page: 1, per_page: 10), :total_pages
  end

  test "the user list renders" do
    without_compiling_packs { get '/admin/user' }
    assert_response :success
  end

  test "deleting a user redirects to a working user list" do
    victim = users(:two)

    without_compiling_packs do
      delete "/admin/user/#{victim.id}/delete"
      assert_redirected_to '/admin/user'
      follow_redirect!
    end

    assert_response :success
    assert_not User.exists?(victim.id)
  end

  private

  # The RailsAdmin layout includes its webpack pack, which tests don't build.
  def without_compiling_packs(&block)
    Webpacker.manifest.stub(:lookup!, '/packs-test/stub.js', &block)
  end
end
