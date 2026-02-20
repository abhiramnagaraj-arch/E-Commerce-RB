class Admin::DashboardController < ApplicationController
  before_action :require_admin

  def index
    @total_orders = Order.count
    @total_revenue = Order.delivered.sum(:total)
    @placed_orders = Order.placed.count
    @confirmed_orders = Order.confirmed.count
    @shipped_orders = Order.shipped.count
    @delivered_orders = Order.delivered.count
  end

  private

  def require_admin
    redirect_to root_path unless current_user&.admin?
  end
end
