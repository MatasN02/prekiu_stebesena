class TrackingController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    @customer_order = CustomerOrder.find_by!(tracking_token: params[:token])
  end
end