class CreateWarehouseLines < ActiveRecord::Migration[8.1]
  def change
    create_table :warehouse_lines do |t|
      t.string :order_number
      t.integer :part_id
      t.string :part_code
      t.string :supplier
      t.integer :quantity
      t.string :status
      t.string :box_code
      t.datetime :received_at
      t.index :order_number
      t.index :status
      t.timestamps
    end
  end
end
