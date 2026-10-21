class AnomalyDetector
  NEW_LIMIT     = 24.hours
  SHIPPED_LIMIT = 5.days

  def self.run
    new.run
  end

  def run
    created = 0
    CustomerOrder.where.not(status: %w[pristatytas atšauktas]).find_each do |order|
      check(order).each do |kind, message|
        created += 1 if report(order, kind, message)
      end
    end
    resolve_fixed
    created
  end

  private

  # Grąžina [[kind, message], ...]
  def check(order)
    found = []

    if order.expected_delivery_at && order.expected_delivery_at < Time.current
      days = ((Time.current - order.expected_delivery_at) / 1.day).ceil
      found << ["overdue", "Pristatymas vėluoja ~#{days} d."]
    end

    if order.status == "naujas" && order.created_at < NEW_LIMIT.ago
      found << ["stuck_new", "Užsakymas „naujas“ ilgiau nei 24 val."]
    end

    if order.status == "išsiųstas" && order.updated_at < SHIPPED_LIMIT.ago
      found << ["stuck_shipped", "„Išsiųstas“ ilgiau nei 5 d. be pristatymo"]
    end

    found
  end

  def report(order, kind, message)
    return false if Anomaly.open.exists?(customer_order: order, kind: kind)
    anomaly = Anomaly.create!(customer_order: order, kind: kind, message: message)
    AnomalyMailer.alert(anomaly).deliver_later if defined?(AnomalyMailer)
    true
  end

  # Uždaro nuokrypius, kurių sąlyga nebegalioja
  def resolve_fixed
    Anomaly.open.includes(:customer_order).find_each do |a|
      o = a.customer_order
      still = o && !%w[pristatytas atšauktas].include?(o.status) && check(o).any? { |k, _| k == a.kind }
      a.update!(resolved_at: Time.current) unless still
    end
  end
end