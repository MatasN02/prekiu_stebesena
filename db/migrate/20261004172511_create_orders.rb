class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :product_name
      t.integer :quantity
      t.string :status
      t.string :location

      t.timestamps
    end
  end
end
