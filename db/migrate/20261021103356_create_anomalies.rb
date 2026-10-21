class CreateAnomalies < ActiveRecord::Migration[8.1]
  def change
    create_table :anomalies do |t|
      t.references :customer_order, null: false, foreign_key: true
      t.string :kind
      t.string :message
      t.datetime :resolved_at

      t.timestamps
    end
  end
end
