require "securerandom"
require "test_helper"

class RecordSheetIndexTest < ActiveSupport::TestCase
  test "stores mapping from record_id to sheet and row" do
    record = Record.create!(
      request_id: "request-#{SecureRandom.uuid}",
      user: users(:one),
      company_name: "ABC",
      product_name: "제품1",
      quantity: 1
    )
    mapping = RecordSheetIndex.create!(
      record_id: record.record_id,
      sheet_name: "ABC",
      row_number: 42
    )

    assert_equal mapping, record.reload.record_sheet_index
    assert_equal "ABC", mapping.sheet_name
    assert_equal 42, mapping.row_number
  end

  test "rejects duplicate mapping for the same record_id" do
    existing = record_sheet_indices(:one)
    duplicate = RecordSheetIndex.new(
      record_id: existing.record_id,
      sheet_name: "MASTER",
      row_number: 10
    )

    assert_not duplicate.valid?
  end
end
