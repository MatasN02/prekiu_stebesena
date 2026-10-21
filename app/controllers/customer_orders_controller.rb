class CustomerOrdersController < ApplicationController
  before_action :set_customer_order, only: %i[show edit update destroy]

  def index
    @customer_orders = current_user.customer_orders.order(created_at: :desc)
  end

  def show; end

  def new
    @customer_order = current_user.customer_orders.build
  end

  def edit; end

  def create
    @customer_order = current_user.customer_orders.build(customer_order_params)
    if @customer_order.save
      redirect_to customer_orders_path, notice: "Užsakymas sukurtas."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @customer_order.update(customer_order_params)
      redirect_to customer_orders_path, notice: "Užsakymas atnaujintas."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @customer_order.destroy
    redirect_to customer_orders_path, notice: "Užsakymas ištrintas."
  end

  private

  def set_customer_order
    @customer_order = current_user.customer_orders.find(params[:id])
  end

  def customer_order_params
  params.require(:customer_order).permit(:product_name, :quantity, :status, :expected_delivery_at)
end
end