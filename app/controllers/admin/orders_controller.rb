class Admin::OrdersController < ApplicationController
  before_action :require_admin

  def index
    @orders = Order.includes(:user).order(created_at: :desc)
  end

  def update
    @order = Order.find(params[:id])

    if Order.statuses.keys.include?(params[:status])
      @order.update(status: params[:status])
      redirect_to admin_orders_path, notice: "Order updated successfully"
    else
      redirect_to admin_orders_path, alert: "Invalid status"
    end
  end


  private

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied"
    end
  end
end
