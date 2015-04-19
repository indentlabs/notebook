require 'test_helper'

# Tests for the MainController class, which serves the model-non-specific
# pages of the site, like the front page.
class MainControllerTest < ActionController::TestCase
  test 'should get index' do
    get :index
    assert_response :success
  end
end
