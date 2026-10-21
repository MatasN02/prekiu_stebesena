module Admin
  class AnomaliesController < ApplicationController
    before_action :require_admin

    def index
      @anomalies = Anomaly.open.includes(customer_order: :user).order(created_at: :desc)
    end

    def scan
      count = AnomalyDetector.run
      redirect_to admin_anomalies_path, notice: "Patikra baigta. Naujų nuokrypių: #{count}."
    end

    def update
      Anomaly.find(params[:id]).update!(resolved_at: Time.current)
      redirect_to admin_anomalies_path, notice: "Pažymėta kaip išspręsta."
    end

    private

    def require_admin
      redirect_to root_path, alert: "Tik atsakingam asmeniui." unless current_user.admin?
    end
  end
end