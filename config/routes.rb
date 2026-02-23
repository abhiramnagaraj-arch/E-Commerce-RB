Rails.application.routes.draw do

  # -----------------
  # Admin Routes
  # -----------------
  namespace :admin do
    root "dashboard#index"
    resources :orders
    resources :products
    resources :users
  end

  # -----------------
  # Public Products
  # -----------------
  resources :products, only: [:index, :show]

  # -----------------
  # Cart
  # -----------------
  post   "cart/add/:id",      to: "cart#add",      as: "add_to_cart"
  post   "cart/decrease/:id", to: "cart#decrease", as: "decrease_cart"
  delete "cart/remove/:id",   to: "cart#remove",   as: "remove_from_cart"
  get    "cart",              to: "cart#show",     as: "cart"
  post   "cart/checkout",     to: "cart#checkout", as: "checkout"

  # -----------------
  # Authentication
  # -----------------
  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # -----------------
  # Users
  # -----------------
  resources :users, only: [:new, :create]

  # -----------------
  # Orders (User Side)
  # -----------------
  resources :orders, only: [:index, :show, :create] do
    member do
      patch :cancel
    end
  end

  # -----------------
  root "products#index"
end