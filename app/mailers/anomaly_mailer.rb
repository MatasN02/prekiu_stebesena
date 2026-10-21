class AnomalyMailer < ApplicationMailer
  default from: "stebesena@prekiu-stebesena.lt"

  def alert(anomaly)
    @anomaly = anomaly
    @order = anomaly.customer_order
    recipients = User.where(admin: true).pluck(:email)
    mail(to: recipients, subject: "⚠️ Nuokrypis: #{anomaly.kind_label}")
  end
end