Rails.application.routes.draw do
  resources :products, only: [:index, :show]

    namespace :admin do
    resources :products
  end

  post   "cart/add/:id",      to: "cart#add",      as: "add_to_cart"
  post   "cart/decrease/:id", to: "cart#decrease", as: "decrease_cart"
  delete "cart/remove/:id",   to: "cart#remove",   as: "remove_from_cart"
  get    "cart",              to: "cart#show",     as: "cart"
  post   "cart/checkout",     to: "cart#checkout", as: "checkout"
  
  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :users,  only: [:new, :create]
  resources :orders, only: [:index, :show, :create]

  root "products#index"
end
