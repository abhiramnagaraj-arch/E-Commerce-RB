class Admin::UsersController < ApplicationController
  before_action :require_admin

  def index
    @users = User.all.order(created_at: :desc)
  end

  private

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied"
    end
  end
end
