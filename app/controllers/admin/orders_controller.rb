class Admin::OrdersController < ApplicationController
  before_action :require_admin

  def index
    @orders = Order.includes(:user).order(created_at: :desc)
  end

  def show
    @order = Order.find(params[:id])
  end

  def update
  @order = Order.find(params[:id])
  new_status = params[:status]

  if Order.statuses.keys.include?(new_status) &&
     Order.statuses[new_status] >= Order.statuses[@order.status]

    @order.update(status: new_status)
    redirect_to admin_orders_path, notice: "Order updated successfully"
  else
    redirect_to admin_orders_path, alert: "Invalid status transition"
  end
end

  private

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied"
    end
  end
end