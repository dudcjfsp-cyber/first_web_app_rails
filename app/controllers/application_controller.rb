class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
  helper_method :current_user, :signed_in?

  private

  def current_user
    @current_user ||= session_user
  end

  def signed_in?
    current_user.present?
  end

  def session_user
    return if session[:user_id].blank?

    User.find_by(id: session[:user_id])
  end

  def require_sign_in
    return if signed_in?

    redirect_to login_path, alert: "로그인이 필요합니다."
  end
end
