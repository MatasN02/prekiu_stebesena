class CustomerOrder < ApplicationRecord
  STATUSES = %w[naujas apdorojamas išsiųstas pristatytas atšauktas].freeze

  belongs_to :user
  has_many :order_status_changes, dependent: :destroy
  has_secure_token :tracking_token

  attribute :status, :string, default: "naujas"

  validates :product_name, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :status, inclusion: { in: STATUSES }

  before_create :set_default_delivery_date
  after_create  :log_initial_status
  after_update  :log_status_change, if: :saved_change_to_status?

    after_create_commit  -> {
    broadcast_prepend_to [user, "customer_orders"], target: "customer_orders"
    broadcast_prepend_to "admin_orders", target: "admin_orders",
                         partial: "admin/orders/order", locals: { order: self }
  }
  after_update_commit  -> {
    broadcast_replace_to [user, "customer_orders"]
    broadcast_replace_to [self, "tracking"],
                         partial: "tracking/order",
                         locals: { customer_order: self },
                         target: ActionView::RecordIdentifier.dom_id(self, :tracking)
    broadcast_replace_to "admin_orders",
                         partial: "admin/orders/order", locals: { order: self },
                         target: ActionView::RecordIdentifier.dom_id(self, :admin)
  }
  after_destroy_commit -> {
    broadcast_remove_to [user, "customer_orders"]
    broadcast_remove_to "admin_orders", target: ActionView::RecordIdentifier.dom_id(self, :admin)
  }
  private

  def set_default_delivery_date
    self.expected_delivery_at ||= 3.days.from_now
  end

  def log_initial_status
    order_status_changes.create!(from_status: nil, to_status: status)
  end

   ALLOWED = {
    "naujas"      => %w[apdorojamas atšauktas],
    "apdorojamas" => %w[išsiųstas atšauktas],
    "išsiųstas"   => %w[pristatytas atšauktas],
    "pristatytas" => [],
    "atšauktas"   => []
  }.freeze

  def log_status_change
    from = status_before_last_save
    order_status_changes.create!(from_status: from, to_status: status)
    unless ALLOWED.fetch(from, []).include?(status)
      anomaly = Anomaly.create!(customer_order: self, kind: "bad_sequence",
                          message: "Neleistinas perėjimas: #{from} → #{status}")
       AnomalyMailer.alert(anomaly).deliver_later
    end
  end
end