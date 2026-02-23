class OrdersController < ApplicationController
  before_action :require_login

  def index
    @orders = current_user.orders
                          .includes(order_items: :product)
                          .order(created_at: :desc)
  end

  def show
    @order = current_user.orders.find(params[:id])
  end

  def create
    session[:cart] ||= {}

    if session[:cart].empty?
      redirect_to cart_path, alert: "Cart is empty"
      return
    end

    products = Product.where(id: session[:cart].keys)

    total = products.sum do |product|
      product.price * session[:cart][product.id.to_s]
    end

    order = current_user.orders.create!(
      status: :placed,
      total_amount: total
    )

    products.each do |product|
      quantity = session[:cart][product.id.to_s]

      order.order_items.create!(
        product: product,
        quantity: quantity,
        price: product.price
      )

      product.decrement!(:stock, quantity)
    end

    session[:cart] = {}

    redirect_to orders_path, notice: "Order placed successfully!"
  end

  private

  def require_login
    redirect_to login_path unless current_user
  end
  end
  def cancel
  @order = current_user.orders.find(params[:id])

  if @order.placed? || @order.confirmed?
    @order.update(status: :cancelled)
    redirect_to orders_path, notice: "Order cancelled"
  else
    redirect_to orders_path, alert: "Cannot cancel this order"
  end
end