namespace :anomalies do
  desc "Vienkartinė patikra"
  task scan: :environment do
    puts "Nauji nuokrypiai: #{AnomalyDetector.run}"
  end

  desc "Kartoja patikrą kas 5 minutes"
  task watch: :environment do
    loop do
      puts "[#{Time.current}] Nauji nuokrypiai: #{AnomalyDetector.run}"
      sleep 300
    end
  end
end