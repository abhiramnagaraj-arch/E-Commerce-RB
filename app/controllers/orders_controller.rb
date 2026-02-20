class OrdersController < ApplicationController
  before_action :require_login

  def index
    @orders = current_user.orders
                          .includes(:order_items => :product)
                          .order(created_at: :desc)
  end

  def show
    @order = current_user.orders.find(params[:id])
  end

  private

  def require_login
    redirect_to login_path unless current_user
  end
end