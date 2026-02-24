require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "defaults to member role" do
    user = User.new(email: "new@example.com", auth_uid: "auth-new")

    assert_equal "member", user.role
    assert user.valid?
  end
end
