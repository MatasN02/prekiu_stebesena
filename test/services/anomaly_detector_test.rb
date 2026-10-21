require "test_helper"

class AnomalyDetectorTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "t@t.lt", password: "slaptazodis1")
  end

  test "vėluojantis užsakymas sukuria nuokrypį" do
    order = @user.customer_orders.create!(product_name: "Alyva", quantity: 1,
              status: "išsiųstas", expected_delivery_at: 3.days.ago)
    AnomalyDetector.run
    assert Anomaly.open.exists?(customer_order: order, kind: "overdue")
  end

  test "nuokrypis nesidubliuoja" do
    @user.customer_orders.create!(product_name: "Alyva", quantity: 1,
              status: "išsiųstas", expected_delivery_at: 3.days.ago)
    AnomalyDetector.run
    assert_no_difference "Anomaly.count" do
      AnomalyDetector.run
    end
  end

  test "pristatytas užsakymas nekelia nuokrypio" do
    @user.customer_orders.create!(product_name: "Alyva", quantity: 1,
              status: "pristatytas", expected_delivery_at: 3.days.ago)
    AnomalyDetector.run
    assert_equal 0, Anomaly.count
  end

  test "kiekis turi būti teigiamas" do
    order = @user.customer_orders.build(product_name: "X", quantity: 0)
    assert_not order.valid?
  end
end