require 'test_helper'
require 'has_privacy_test'

# Tests for the Location model class
class ItemTest < ActiveSupport::TestCase
  include HasPrivacyTest

  setup do
    @item = create(:item)
    @object = @item
  end

  test 'item not valid without a name' do
    @item.name = nil

    refute @item.valid?, 'Item name is not being validated for presence'
  end
end
