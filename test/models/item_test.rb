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

  test 'item is_public scope' do
    public_universe = create(:universe, privacy: 'public')
    private_universe = create(:universe, privacy: 'private')

    pub_item_pub_universe = create(:item, privacy: 'public', universe: public_universe)
    pub_item_priv_universe = create(:item, privacy: 'public', universe: private_universe)
    priv_item_pub_universe = create(:item, privacy: 'private', universe: public_universe)
    priv_item_priv_universe = create(:item, privacy: 'private', universe: private_universe)

    public_scope = Item.is_public

    assert_includes public_scope, pub_item_pub_universe, "didn't contain a public item in a public universe"
    assert_includes public_scope, pub_item_priv_universe, "didn't contain a public item in a private universe"
    assert_includes public_scope, priv_item_pub_universe, "didn't contain a private item in a public universe"

    refute_includes public_scope, priv_item_priv_universe, "contained a private item in a private universe"
  end
end
