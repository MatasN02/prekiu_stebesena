class CreateWarehouseAnomalies < ActiveRecord::Migration[8.1]
  def change
    create_table :warehouse_anomalies do |t|
      t.string :order_number
      t.string :kind
      t.string :part_code
      t.string :message
      t.datetime :resolved_at

      t.timestamps
    end
  end
end
