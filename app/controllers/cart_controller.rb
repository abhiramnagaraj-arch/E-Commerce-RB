class CartController < ApplicationController

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

end