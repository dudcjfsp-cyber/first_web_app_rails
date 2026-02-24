require "securerandom"
require "test_helper"

class ExportsControllerTest < ActionDispatch::IntegrationTest
  test "redirects to login when not signed in" do
    get export_records_url
    assert_redirected_to login_url
  end

  test "downloads csv for current user with utc date filter" do
    local_user = sign_in_local_member

    Record.create!(
      request_id: "request-#{SecureRandom.uuid}",
      user: local_user,
      submitted_at_utc: Time.utc(2026, 2, 24, 9, 0, 0),
      company_name: "LOCALCO",
      product_name: "item-a",
      quantity: 7
    )
    Record.create!(
      request_id: "request-#{SecureRandom.uuid}",
      user: local_user,
      submitted_at_utc: Time.utc(2026, 2, 25, 9, 0, 0),
      company_name: "LOCALCO",
      product_name: "item-b",
      quantity: 9
    )
    Record.create!(
      request_id: "request-#{SecureRandom.uuid}",
      user: users(:two),
      submitted_at_utc: Time.utc(2026, 2, 24, 10, 0, 0),
      company_name: "OTHERCO",
      product_name: "item-c",
      quantity: 11
    )

    get export_records_url, params: { from_date: "2026-02-24", to_date: "2026-02-24" }

    assert_response :success
    assert_equal "text/csv", response.media_type
    assert_includes response.headers["Content-Disposition"], "records_from-2026-02-24_to-2026-02-24.csv"

    lines = response.body.split("\n").map(&:strip)
    assert_equal "\"record_id\",\"submitted_at_utc\",\"user_email\",\"company_name\",\"product_name\",\"quantity\"", lines.first
    assert_equal 2, lines.length
    assert_includes lines.second, "\"local-member@example.com\""
    assert_includes lines.second, "\"LOCALCO\""
    assert_includes lines.second, "\"item-a\""
    assert_includes lines.second, "\"7\""
    assert_includes lines.second, "\"2026-02-24"
  end

  private

  def sign_in_local_member
    post login_submit_url, params: {
      email: "local-member@example.com",
      password: ENV.fetch("SIMPLE_LOGIN_PASSWORD", "pass1234")
    }

    User.find_by!(email: "local-member@example.com")
  end
end
