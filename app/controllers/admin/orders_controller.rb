module Admin
  class OrdersController < ApplicationController
    before_action :require_admin

    def index
      @orders = CustomerOrder.includes(:user).order(created_at: :desc)
      @orders = @orders.where(status: params[:status]) if params[:status].present?
      @counts = CustomerOrder.group(:status).count
    end

    def update
      order = CustomerOrder.find(params[:id])
      if order.update(status: params.require(:customer_order).permit(:status)[:status])
        redirect_to admin_orders_path, notice: "Būsena atnaujinta."
      else
        redirect_to admin_orders_path, alert: order.errors.full_messages.to_sentence
      end
    end

    private

    def require_admin
      redirect_to root_path, alert: "Tik atsakingam asmeniui." unless current_user.admin?
    end
  end
end