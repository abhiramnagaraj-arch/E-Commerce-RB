class CartController < ApplicationController
  before_action :require_login, only: [:checkout]

  def add
    session[:cart] ||= {}
    product = Product.find(params[:id])
    product_id = product.id.to_s

    # Check if stock is zero
    if product.stock <= 0
      redirect_to products_path, alert: "Product is out of stock"
      return
    end

    current_quantity = session[:cart][product_id] || 0

    # Prevent adding more than available stock
    if current_quantity >= product.stock
      redirect_to cart_path, alert: "Cannot add more than available stock"
      return
    end

    session[:cart][product_id] = current_quantity + 1
    redirect_to cart_path
  end

  def checkout
    return redirect_to cart_path, alert: "Cart is empty" if session[:cart].blank?

    ActiveRecord::Base.transaction do
      order = Order.create!(
        user: current_user,
        total: 0,
        status: "placed"
      )

      total_price = 0

      session[:cart].each do |product_id, quantity|
        product = Product.find(product_id)

        if product.stock < quantity
          raise ActiveRecord::Rollback, "Not enough stock"
        end

        subtotal = product.price * quantity

        OrderItem.create!(
          order: order,
          product: product,
          quantity: quantity,
          price: product.price
        )

        product.update!(stock: product.stock - quantity)
        total_price += subtotal
      end

      order.update!(total: total_price)
    end

    session[:cart] = {}
    redirect_to products_path, notice: "Order placed successfully!"
  end

  def show
    @cart_items = session[:cart] || {}
    @products   = Product.find(@cart_items.keys)

    @total_items = @cart_items.values.sum

    @total_price = @products.sum do |product|
      product.price * @cart_items[product.id.to_s]
    end
  end

  def decrease
    product_id = params[:id].to_s

    if session[:cart][product_id] > 1
      session[:cart][product_id] -= 1
    else
      session[:cart].delete(product_id)
    end

    return redirect_to cart_path unless session[:cart]
    redirect_to cart_path
  end

  def remove
    session[:cart]&.delete(params[:id].to_s)
    redirect_to cart_path
  end

  private

  def require_login
    unless current_user
      redirect_to login_path, alert: "You must be logged in to checkout."
    end
  end
end
