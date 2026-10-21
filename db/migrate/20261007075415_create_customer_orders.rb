class CreateCustomerOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_orders do |t|
      t.string :product_name
      t.integer :quantity
      t.string :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
