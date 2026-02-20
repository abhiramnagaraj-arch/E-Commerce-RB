class Admin::DashboardController < ApplicationController
  def index
    @total_orders = Order.count
    @total_revenue = Order.delivered.sum(:total_amount)

    @placed_orders = Order.placed.count
    @confirmed_orders = Order.confirmed.count
    @shipped_orders = Order.shipped.count
    @delivered_orders = Order.delivered.count
  end
end
