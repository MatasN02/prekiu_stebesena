class WarehouseAnomalyDetector
  STUCK_AFTER = 7.days

  def self.run = new.run

  def run
    created = 0
    (stuck_received + qty_changed + no_supplier + duplicate_scan).each do |a|
      next if WarehouseAnomaly.unresolved.exists?(order_number: a[:order_number], kind: a[:kind], part_code: a[:part_code])
      WarehouseAnomaly.create!(a)
      created += 1
    end
    created
  end

  private

  def stuck_received
    packed = WarehouseLine.where(status: "Detalė supakuota").pluck(:order_number, :part_id).to_set
    WarehouseLine.where(status: "Sėkmingai gauta", box_code: nil)
                 .where("received_at < ?", STUCK_AFTER.ago).map do |l|
      next if packed.include?([l.order_number, l.part_id])
      { order_number: l.order_number, kind: "stuck_received", part_code: l.part_code,
        message: "Detalė gauta #{l.received_at&.to_date}, bet nesupakuota ilgiau nei 7 d." }
    end.compact.uniq
  end

  def qty_changed
    WarehouseLine.where(status: "Detalės gavimo kiekis pakeistas").map do |l|
      { order_number: l.order_number, kind: "qty_changed", part_code: l.part_code,
        message: "Gavimo kiekis pakeistas (kiekis: #{l.quantity})" }
    end.uniq
  end

  def no_supplier
    WarehouseLine.where("supplier IS NULL OR supplier = '' OR supplier LIKE 'Nėra nurodyto%'").map do |l|
      { order_number: l.order_number, kind: "no_supplier", part_code: l.part_code,
        message: "Detalei nenurodytas tiekėjas" }
    end.uniq
  end

  def duplicate_scan
    WarehouseLine.where(status: "Sėkmingai gauta")
                 .group(:order_number, :part_id, :part_code)
                 .having("COUNT(*) > 1").count.map do |(order, _pid, code), n|
      { order_number: order, kind: "duplicate_scan", part_code: code,
        message: "Ta pati detalė gauta #{n} kartus" }
    end
  end
end