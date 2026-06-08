require 'test_helper'

class PageUnlockPromoCodeTest < ActiveSupport::TestCase
  test "activate! consumes one use and grants promotions" do
    code = PageUnlockPromoCode.create!(
      code:           'TESTONE',
      page_types:     ['Character'],
      uses_remaining: 1,
      days_active:    30
    )

    assert code.activate!(users(:one))
    assert_equal 0, code.reload.uses_remaining
    assert users(:one).promotions.exists?(page_unlock_promo_code_id: code.id)
  end

  test "activate! is a no-op once uses are exhausted" do
    code = PageUnlockPromoCode.create!(
      code:           'TESTTWO',
      page_types:     ['Character'],
      uses_remaining: 1,
      days_active:    30
    )

    assert code.activate!(users(:one))
    assert_not code.activate!(users(:two))
    assert_equal 0, code.reload.uses_remaining
  end

  test "activate! cannot be redeemed twice by the same user" do
    code = PageUnlockPromoCode.create!(
      code:           'TESTTHREE',
      page_types:     ['Character'],
      uses_remaining: 5,
      days_active:    30
    )

    assert code.activate!(users(:one))
    assert_not code.activate!(users(:one)), 'same user should not be able to redeem twice'
    assert_equal 4, code.reload.uses_remaining, 'only one use should have been consumed'
  end
end
