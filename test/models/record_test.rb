require "securerandom"
require "test_helper"

class RecordTest < ActiveSupport::TestCase
  test "creates record with generated uuid and utc timestamp" do
    record = Record.create!(
      request_id: "request-#{SecureRandom.uuid}",
      user: users(:one),
      company_name: "ABC",
      product_name: "제품1",
      quantity: 10
    )

    assert_match(/\A[0-9a-f\-]{36}\z/, record.record_id)
    assert record.submitted_at_utc.utc?
  end

  test "updates and deletes record" do
    record = records(:one)

    record.update!(quantity: 99)
    assert_equal 99, record.reload.quantity

    assert_difference("Record.count", -1) do
      record.destroy!
    end
  end
end
