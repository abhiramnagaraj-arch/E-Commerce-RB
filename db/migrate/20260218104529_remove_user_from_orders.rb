class RemoveUserFromOrders < ActiveRecord::Migration[7.0]
  def change
    remove_reference :orders, :user, foreign_key: true
  end
end
