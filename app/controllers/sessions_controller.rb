class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    user = find_or_build_user_from(auth)
    user.save!
    session[:user_id] = user.id

    redirect_to root_path, notice: "로그인되었습니다."
  rescue ActiveRecord::RecordInvalid
    redirect_to root_path, alert: "로그인에 실패했습니다."
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "로그아웃되었습니다."
  end

  def failure
    redirect_to root_path, alert: "로그인에 실패했습니다."
  end

  private

  def find_or_build_user_from(auth)
    user = User.find_or_initialize_by(google_uid: auth.uid)
    user.email = auth.info.email
    user.role = initial_role_for(user)
    user
  end

  def initial_role_for(user)
    return user.role if user.persisted?
    return "admin" if initial_admin_email?(user.email)

    "member"
  end

  def initial_admin_email?(email)
    expected = ENV.fetch("INITIAL_ADMIN_EMAIL", "").strip.downcase
    return false if expected.empty?

    email.to_s.strip.downcase == expected
  end
end
