class RecordAccessPolicy
  def initialize(user)
    @user = user
  end

  def visible_records(scope = Record.all)
    return scope if admin?

    scope.where(user_id: @user.id)
  end

  def can_modify_record?(record)
    admin? || record.user_id == @user.id
  end

  def can_change_roles?
    admin?
  end

  private

  def admin?
    @user.role == "admin"
  end
end
