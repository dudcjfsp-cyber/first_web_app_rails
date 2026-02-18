class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
  helper_method :current_user, :signed_in?

  private

  def current_user
    @current_user ||= session_user || local_development_user
  end

  def signed_in?
    session[:user_id].present?
  end

  def session_user
    return if session[:user_id].blank?

    User.find_by(id: session[:user_id])
  end

  def local_development_user
    User.find_or_create_by!(email: "local-member@example.com") do |user|
      user.google_uid = "local-member"
      user.role = "member"
    end
  end
end
