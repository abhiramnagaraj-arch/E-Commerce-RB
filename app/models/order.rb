class Order < ApplicationRecord
  # app/models/order.rb
belongs_to :user
has_many :order_items, dependent: :destroy

end
