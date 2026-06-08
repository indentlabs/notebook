require 'test_helper'
require 'ostruct'

class StripeEventLogTest < ActiveSupport::TestCase
  test "record_once returns true the first time and false on redelivery" do
    event = OpenStruct.new(id: 'evt_test_123', type: 'invoice.payment_succeeded')

    assert StripeEventLog.record_once(event), 'first delivery should be processed'
    assert_not StripeEventLog.record_once(event), 'redelivery should be skipped'

    assert_equal 1, StripeEventLog.where(event_id: 'evt_test_123').count
  end
end
