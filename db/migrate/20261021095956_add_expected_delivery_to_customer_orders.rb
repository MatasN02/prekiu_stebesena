class AddExpectedDeliveryToCustomerOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :customer_orders, :expected_delivery_at, :datetime
  end
end
