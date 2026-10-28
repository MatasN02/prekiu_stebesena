module Admin
  class WarehouseAnomaliesController < ApplicationController
    before_action :require_admin

    def update
      WarehouseAnomaly.find(params[:id]).update!(resolved_at: Time.current)
      redirect_to admin_anomalies_path, notice: "Pažymėta kaip išspręsta."
    end

    private

    def require_admin
      redirect_to root_path, alert: "Tik atsakingam asmeniui." unless current_user.admin?
    end
  end
end