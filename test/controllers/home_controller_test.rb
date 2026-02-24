require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "redirects to login when not signed in" do
    get root_url
    assert_redirected_to login_url
  end

  test "should get index" do
    sign_in_local_member
    get home_index_url
    assert_response :success
  end

  test "should get root" do
    sign_in_local_member
    get root_url
    assert_response :success
  end

  test "filters records by utc date range for current user" do
    user = sign_in_local_member

    Record.create!(
      request_id: "home-test-a",
      user: user,
      submitted_at_utc: Time.utc(2026, 2, 24, 8, 0, 0),
      company_name: "A",
      product_name: "filter-hit",
      quantity: 1
    )
    Record.create!(
      request_id: "home-test-b",
      user: user,
      submitted_at_utc: Time.utc(2026, 2, 25, 8, 0, 0),
      company_name: "A",
      product_name: "filter-miss",
      quantity: 2
    )

    get root_url, params: { from_date: "2026-02-24", to_date: "2026-02-24" }

    assert_response :success
    assert_includes response.body, "filter-hit"
    assert_not_includes response.body, "filter-miss"
  end

  private

  def sign_in_local_member
    password = ENV.fetch("SIMPLE_LOGIN_PASSWORD", "pass1234")

    post login_submit_url, params: {
      email: "local-member@example.com",
      password: password
    }

    User.find_by!(email: "local-member@example.com")
  end
end
