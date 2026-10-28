class WarehouseAnomaly < ApplicationRecord
  KINDS = {
    "stuck_received" => "Gauta, bet nesupakuota",
    "qty_changed"    => "Pakeistas gavimo kiekis",
    "no_supplier"    => "Nenurodytas tiekėjas",
    "duplicate_scan" => "Dubliuotas skenavimas"
  }.freeze

  scope :unresolved, -> { where(resolved_at: nil) }

  def kind_label = KINDS.fetch(kind, kind)
end