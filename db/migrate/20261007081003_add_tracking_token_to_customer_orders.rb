class AddTrackingTokenToCustomerOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :customer_orders, :tracking_token, :string
    add_index :customer_orders, :tracking_token, unique: true
  end
end
