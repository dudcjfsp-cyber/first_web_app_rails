require "test_helper"

class RecordAccessPolicyTest < ActiveSupport::TestCase
  test "T9 member can modify only own records" do
    member_policy = RecordAccessPolicy.new(users(:one))

    assert member_policy.can_modify_record?(records(:one))
    assert_not member_policy.can_modify_record?(records(:two))

    visible_ids = member_policy.visible_records(Record.order(:id)).pluck(:id)
    assert_equal [ records(:one).id ], visible_ids
    assert_not member_policy.can_change_roles?
  end

  test "T10 admin can modify all records and roles" do
    admin_policy = RecordAccessPolicy.new(users(:two))

    assert admin_policy.can_modify_record?(records(:one))
    assert admin_policy.can_modify_record?(records(:two))

    visible_ids = admin_policy.visible_records(Record.order(:id)).pluck(:id)
    assert_equal Record.order(:id).pluck(:id), visible_ids
    assert admin_policy.can_change_roles?
  end
end
