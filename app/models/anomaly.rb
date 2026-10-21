class Anomaly < ApplicationRecord
  KINDS = {
    "overdue"       => "Vėluoja pristatymas",
    "stuck_new"     => "Per ilgai „naujas“",
    "stuck_shipped" => "Per ilgai „išsiųstas“",
    "bad_sequence"  => "Neleistina būsenų seka"
  }.freeze

  belongs_to :customer_order

  scope :open, -> { where(resolved_at: nil) }

  def kind_label = KINDS.fetch(kind, kind)

  after_create_commit -> {
    broadcast_prepend_to "admin_anomalies", target: "admin_anomalies",
                         partial: "admin/anomalies/anomaly", locals: { anomaly: self }
  }
  after_update_commit -> {
    broadcast_remove_to "admin_anomalies",
                        target: ActionView::RecordIdentifier.dom_id(self) if resolved_at.present?
  }
end