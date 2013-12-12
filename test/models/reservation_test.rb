require 'test_helper.rb'

class ReservationTest < ActiveSupport::TestCase

  def setup
    @reservation_attrs = { arrival:            Date.today.to_s,
                           departure:          Date.tomorrow.to_s,
                           guests:             2 }

    @visitor_attrs = { firstname:    "FirstnameX",
                       lastname:     "LastnameX",
                       street:       "StreetX 13",
                       zip:          "ZipX",
                       city:         "CityX",
                       country:      "CountryX",
                       mobile:       "0904123456",
                       phone:        "0411234567",
                       email:        "new_user@email.com" }
  end

  test "creation of a new reservation and a new visitor" do

    r = Reservation.new @reservation_attrs.merge(visitor_attributes: @visitor_attrs)
    assert r.save
    assert r.persisted?
    assert r.visitor

  end

  test "creation of only a new reservation" do

    @visitor_attrs[:email] = "user1@email.com"

    r = Reservation.new @reservation_attrs.merge(visitor_attributes: @visitor_attrs)
    assert r.save
    assert r.persisted?
    assert_nil r.visitor

  end

  test "validation of conflicting date range" do

=begin
A = arrival of existing reservation
B = departure of existing reservation
C = arrival of the new reservation
D = departure of the new reservation
=end

    # -.-A-.-.-B-.-
    # -C-.-D-.-.-.-
    r = Reservation.new arrival: Date.today + 4.days, departure: Date.today + 6.days, guests: 1, visitor_attributes: @visitor_attrs
    assert_not r.save

    # -.-A-.-.-B-.-
    # -.-C-D-.-.-.-
    r = Reservation.new arrival: Date.today + 5.days, departure: Date.today + 6.days, guests: 1, visitor_attributes: @visitor_attrs
    assert_not r.save

    # -.-A-.-.-B-.-
    # -.-.-C-D-.-.-
    r = Reservation.new arrival: Date.today + 6.days, departure: Date.today + 7.days, guests: 1, visitor_attributes: @visitor_attrs
    assert_not r.save

    # -.-A-.-.-B-.-
    # -.-.-C-.-D-.-
    r = Reservation.new arrival: Date.today + 6.days, departure: Date.today + 8.days, guests: 1, visitor_attributes: @visitor_attrs
    assert_not r.save

    # -.-A-.-.-B-.-
    # -.-.-C-.-.-D-
    r = Reservation.new arrival: Date.today + 6.days, departure: Date.today + 9.days, guests: 1, visitor_attributes: @visitor_attrs
    assert_not r.save

    # -.-A-.-.-B-.-
    # -C-.-.-.-.-D-
    r = Reservation.new arrival: Date.today + 4.days, departure: Date.today + 9.days, guests: 1, visitor_attributes: @visitor_attrs
    assert_not r.save

    assert_not r.persisted?
    assert_not r.visitor.persisted?

  end

  test "validation of non conflicting date range 1" do

    # -.-A-.-.-B-.-
    # -C-D-.-.-.-.-
    r = Reservation.new arrival: Date.today + 4.days, departure: Date.today + 5.days, guests: 1, visitor_attributes: @visitor_attrs
    assert r.save
    assert r.persisted?
    assert r.visitor.persisted?

  end

  test "validation of non conflicting date range 2" do

    # -.-A-.-.-B-.-
    # -.-.-.-.-C-D-
    r = Reservation.new arrival: Date.today + 8.days, departure: Date.today + 9.days, guests: 1, visitor_attributes: @visitor_attrs
    assert r.save
    assert r.persisted?
    assert r.visitor.persisted?

  end

end
