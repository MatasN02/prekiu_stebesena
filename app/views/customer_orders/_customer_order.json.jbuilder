json.extract! customer_order, :id, :product_name, :quantity, :status, :user_id, :created_at, :updated_at
json.url customer_order_url(customer_order, format: :json)
