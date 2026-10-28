require "csv"

namespace :import do
  desc "Importuoja sandėlio eilutes iš db/import/uzsakymai.csv"
  task lines: :environment do
    path = Rails.root.join("db/import/uzsakymai.csv")
    abort "Nerastas #{path}" unless File.exist?(path)

    WarehouseLine.delete_all
    rows = []

        CSV.foreach(path, headers: true, encoding: "bom|utf-8", quote_char: "\0") do |r|
      time = begin
        Time.strptime(r["CREATED_AT"].to_s.strip, "%m/%d/%Y %I:%M:%S.%N %p")
      rescue ArgumentError
        nil
      end
      box = r["BOX_CODE"].to_s.strip
      rows << {
        order_number: r["ORDER_NUMBER"],
        part_id: r["NPART_ID"].to_i,
        part_code: r["PART_CODE"],
        supplier: r["SUPPLIER"],
        quantity: r["QUANTITY"].to_i,
        status: r["STATUS"].presence,
        box_code: (box == "-" ? nil : box.presence),
        received_at: time,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    WarehouseLine.insert_all(rows)
    puts "Importuota eilučių: #{rows.size}"
  end
end