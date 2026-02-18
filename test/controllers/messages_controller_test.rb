require "securerandom"
require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    RequestIdGate.clear!
  end

  test "stores normalized records when input is valid" do
    request_id = SecureRandom.uuid

    assert_difference("Record.count", 2) do
      post messages_url, params: {
        message: "abc 제품A 10 제품B 20",
        request_id: request_id
      }
    end

    assert_redirected_to root_url
    assert_equal "저장되었습니다.", flash[:notice]
    assert_equal [ "ABC", "ABC" ], Record.order(:id).last(2).map(&:company_name)
  end

  test "returns validation error when request_id is missing" do
    assert_no_difference("Record.count") do
      post messages_url, params: {
        message: "ABC 제품1 10"
      }
    end

    assert_redirected_to root_url
    assert_equal "request_id가 필요합니다.", flash[:alert]
  end

  test "shows number validation message for decimal quantity" do
    assert_no_difference("Record.count") do
      post messages_url, params: {
        message: "ABC 제품1 10.5",
        request_id: SecureRandom.uuid
      }
    end

    assert_redirected_to root_url
    assert_equal "갯수는 숫자만 입력해주세요.", flash[:alert]
  end

  test "rejects duplicated request_id" do
    request_id = SecureRandom.uuid

    post messages_url, params: {
      message: "ABC 제품1 10",
      request_id: request_id
    }

    assert_no_difference("Record.count") do
      post messages_url, params: {
        message: "ABC 제품1 10",
        request_id: request_id
      }
    end

    assert_redirected_to root_url
    assert_equal "이미 처리된 요청입니다.", flash[:alert]
  end
end
