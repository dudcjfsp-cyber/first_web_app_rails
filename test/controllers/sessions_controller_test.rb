require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "shows local login page" do
    get login_url
    assert_response :success
    assert_includes response.body, "간편 로그인"
  end

  test "logs in with local email and password" do
    with_env("SIMPLE_LOGIN_PASSWORD" => "pass1234") do
      post login_submit_url, params: {
        email: "local-member@example.com",
        password: "pass1234"
      }
    end

    assert_redirected_to root_url
    user = User.find_by(email: "local-member@example.com")
    assert_equal "member", user.role
  end

  test "grants admin role for initial admin email on local sign in" do
    admin_email = "owner-local@example.com"

    with_env(
      "SIMPLE_LOGIN_PASSWORD" => "pass1234",
      "INITIAL_ADMIN_EMAIL" => admin_email
    ) do
      post login_submit_url, params: {
        email: admin_email,
        password: "pass1234"
      }
    end

    assert_redirected_to root_url
    user = User.find_by(email: admin_email)
    assert_equal "admin", user.role
  end

  test "rejects local login when password is invalid" do
    with_env("SIMPLE_LOGIN_PASSWORD" => "pass1234") do
      post login_submit_url, params: {
        email: "local-member@example.com",
        password: "wrong"
      }
    end

    assert_redirected_to login_url
    assert_equal "이메일 또는 비밀번호가 올바르지 않습니다.", flash[:alert]
  end

  private

  def with_env(overrides)
    originals = {}
    overrides.each_key { |key| originals[key] = ENV[key] }

    overrides.each { |key, value| ENV[key] = value }
    yield
  ensure
    originals.each { |key, value| ENV[key] = value }
  end
end
