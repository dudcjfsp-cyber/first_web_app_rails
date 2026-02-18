require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  teardown do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  test "T14 grants admin role on first login when email matches INITIAL_ADMIN_EMAIL" do
    with_env("INITIAL_ADMIN_EMAIL" => "owner@example.com") do
      OmniAuth.config.mock_auth[:google_oauth2] = mock_auth(
        uid: "google-owner",
        email: "owner@example.com"
      )

      assert_difference("User.count", 1) do
        get "/auth/google_oauth2/callback"
      end

      assert_redirected_to root_url

      user = User.find_by(email: "owner@example.com")
      assert_equal "admin", user.role
    end
  end

  test "assigns member role when email does not match INITIAL_ADMIN_EMAIL" do
    with_env("INITIAL_ADMIN_EMAIL" => "owner@example.com") do
      OmniAuth.config.mock_auth[:google_oauth2] = mock_auth(
        uid: "google-member",
        email: "member@example.com"
      )

      assert_difference("User.count", 1) do
        get "/auth/google_oauth2/callback"
      end

      assert_redirected_to root_url

      user = User.find_by(email: "member@example.com")
      assert_equal "member", user.role
    end
  end

  private

  def mock_auth(uid:, email:)
    OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: uid,
      info: {
        email: email
      }
    )
  end

  def with_env(overrides)
    originals = {}
    overrides.each_key { |key| originals[key] = ENV[key] }

    overrides.each { |key, value| ENV[key] = value }
    yield
  ensure
    originals.each { |key, value| ENV[key] = value }
  end
end
