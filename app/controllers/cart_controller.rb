class CartController < ApplicationController
  before_action :require_login, only: [:checkout]

  # ADD PRODUCT
  def add
    session[:cart] ||= {}

    product = Product.find(params[:id])
    product_id = product.id.to_s

    if product.stock <= 0
      redirect_back fallback_location: products_path, alert: "Product is out of stock"
      return
    end

    current_quantity = session[:cart][product_id] || 0

    if current_quantity >= product.stock
      redirect_back fallback_location: products_path, alert: "Cannot add more than available stock"
      return
    end

    session[:cart][product_id] = current_quantity + 1

    redirect_back fallback_location: products_path
  end

  # SHOW CART
  def show
    session[:cart] ||= {}

    @cart_items = session[:cart]
    @products   = Product.where(id: @cart_items.keys)

    @total_items = @cart_items.values.sum

    @total_price = @products.sum do |product|
      product.price * @cart_items[product.id.to_s]
    end
  end

  # DECREASE QUANTITY
  def decrease
    session[:cart] ||= {}
    product_id = params[:id].to_s

    if session[:cart][product_id]
      if session[:cart][product_id] > 1
        session[:cart][product_id] -= 1
      else
        session[:cart].delete(product_id)
      end
    end

    redirect_back fallback_location: products_path
  end

  # REMOVE PRODUCT
  def remove
    session[:cart]&.delete(params[:id].to_s)
    redirect_back fallback_location: cart_path
  end

  # CHECKOUT
  def checkout
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
    redirect_to login_path, alert: "You must be logged in to checkout." unless current_user
  end
end
