class WarehouseOrdersController < ApplicationController
  def index
    scope = WarehouseLine.all
    if params[:q].present?
      scope = scope.where("order_number LIKE ? OR part_code LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%")
    end
    scope = scope.where(status: params[:status]) if params[:status].present?

    @statuses = WarehouseLine.group(:status).count
    @orders = scope.group(:order_number)
                   .select("order_number, COUNT(*) AS lines_count, SUM(quantity) AS total_qty, " \
                           "GROUP_CONCAT(DISTINCT box_code) AS box_codes, MAX(received_at) AS last_at")
                   .order("last_at DESC")
                   .limit(100)
  end

  def show
    @number = params[:number]
    @lines = WarehouseLine.where(order_number: @number).order(:received_at)
    raise ActiveRecord::RecordNotFound if @lines.empty?
  end
end