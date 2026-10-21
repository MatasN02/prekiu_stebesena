class CreateOrderStatusChanges < ActiveRecord::Migration[8.1]
  def change
    create_table :order_status_changes do |t|
      t.references :customer_order, null: false, foreign_key: true
      t.string :from_status
      t.string :to_status

      t.timestamps
    end
  end
end
