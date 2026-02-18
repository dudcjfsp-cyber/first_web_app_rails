require "securerandom"
require "test_helper"

class RequestIdGateTest < ActiveSupport::TestCase
  setup do
    RequestIdGate.clear!
  end

  test "returns VALIDATION_ERROR when request_id is missing" do
    result = RequestIdGate.run(request_id: nil)

    assert_not result[:success]
    assert_equal RequestIdGate::VALIDATION_ERROR, result[:error_code]
  end

  test "prevents duplicate execution for same request_id" do
    request_id = SecureRandom.uuid
    execution_count = 0

    first_result = RequestIdGate.run(request_id: request_id) do
      execution_count += 1
      :saved
    end

    second_result = RequestIdGate.run(request_id: request_id) do
      execution_count += 1
      :saved
    end

    assert first_result[:success]
    assert_equal :saved, first_result[:data]

    assert_not second_result[:success]
    assert_equal RequestIdGate::DUPLICATE_REQUEST, second_result[:error_code]
    assert_equal 1, execution_count
  end
end
