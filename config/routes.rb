Rails.application.routes.draw do
  resources :products, only: [:index, :show]

  post   "cart/add/:id",      to: "cart#add",      as: "add_to_cart"
  post   "cart/decrease/:id", to: "cart#decrease", as: "decrease_cart"
  delete "cart/remove/:id",   to: "cart#remove",   as: "remove_from_cart"
  get    "cart",              to: "cart#show",     as: "cart"
  post "cart/checkout", to: "cart#checkout", as: "checkout"

  root "products#index"
end
