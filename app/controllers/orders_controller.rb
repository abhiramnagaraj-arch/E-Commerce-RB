class OrdersController < ApplicationController
  before_action :require_login

  def index
    @orders = current_user.orders
  end

  def show
    @order = current_user.orders.find(params[:id])
  end


  def create
    order = current_user.orders.create(total_amount: calculate_cart_total)

    session[:cart].each do |product_id, quantity|
      product = Product.find(product_id)

      order.order_items.create(
        product: product,
        quantity: quantity,
        price: product.price
      )
@order = current_user.orders.build

      product.update(stock: product.stock - quantity)
    end

    session[:cart] = {}
    redirect_to order_path(order)
  end

  private

  def calculate_cart_total
    session[:cart].sum do |product_id, quantity|
      product = Product.find(product_id)
      product.price * quantity
    end
  end
end
