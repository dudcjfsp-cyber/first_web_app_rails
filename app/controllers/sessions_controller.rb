require "digest"

class SessionsController < ApplicationController
  def new
  end

  def local_create
    email = params[:email].to_s.strip.downcase
    password = params[:password].to_s

    if email.blank? || password != simple_login_password
      redirect_to login_path, alert: "이메일 또는 비밀번호가 올바르지 않습니다."
      return
    end

    user = find_or_build_local_user(email)
    user.save!
    session[:user_id] = user.id

    redirect_to root_path, notice: "로그인되었습니다."
  rescue ActiveRecord::RecordInvalid
    redirect_to login_path, alert: "로그인에 실패했습니다."
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "로그아웃되었습니다."
  end

  private

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

  def simple_login_password
    ENV.fetch("SIMPLE_LOGIN_PASSWORD", "pass1234")
  end

  def find_or_build_local_user(email)
    user = User.find_or_initialize_by(email: email)
    user.auth_uid = local_uid_for(email) if user.auth_uid.blank?
    user.role = initial_role_for(user) unless user.persisted?
    user
  end

  def local_uid_for(email)
    "local-#{Digest::SHA256.hexdigest(email)[0, 24]}"
  end
end
