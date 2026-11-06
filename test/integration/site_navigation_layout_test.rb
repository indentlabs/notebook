require 'test_helper'

# The site navigation's layout lives in CSS (app/assets/stylesheets/site-navigation.scss),
# keyed off a data-site-nav attribute that layouts/_site_navigation.html.erb sets on
# <html> before first paint. These tests pin down that contract in each layout that
# renders the sidebar, so a layout can't quietly fall back to sizing things from
# JavaScript (which is how the rail ended up covering pages on tablets).
class SiteNavigationLayoutTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
  end

  def assert_site_nav_layout(start_collapsed: false)
    assert_response :success

    # State is set on <html> before paint, and the store is registered for Alpine.
    assert_includes response.body, "root.setAttribute('data-site-nav'"
    assert_includes response.body, "Alpine.store('siteNav'"
    assert_includes response.body, "var startCollapsed = #{start_collapsed};"

    # The sidebar, and the page chrome beside it, take their sizes from CSS.
    assert_select 'nav.site-nav#site-navigation'
    assert_select 'header.site-nav-padding'
    assert_select 'main.site-nav-margin'
    assert_select 'footer.site-nav-margin'

    # Nothing measures the window to lay out the rail any more.
    assert_no_match(/\bshowSidebar\b/, response.body)
    assert_no_match(/md:ml-(16|56)/, response.body)
  end

  test "application layout" do
    sign_in @user
    get dashboard_path
    assert_site_nav_layout
  end

  test "forum layout" do
    sign_in @user
    get thredded_path
    assert_site_nav_layout
    assert_select 'nav.thredded-nav.site-nav-margin'
  end

  test "editor layout starts with the rail collapsed" do
    document = Document.create!(title: 'Draft', body: '<p>Words.</p>', user: @user)

    sign_in @user
    get edit_document_path(document)
    assert_site_nav_layout(start_collapsed: true)
  end

  test "signed-out visitors get no rail and no offset" do
    get thredded_path

    assert_response :success
    assert_select 'nav.site-nav', count: 0
    assert_includes response.body, 'var signedIn = false;'
  end
end
