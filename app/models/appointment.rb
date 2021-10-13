# frozen_string_literal: true

class Appointment
  include Mongoid::Document
  extend Enumerize

  BUFFER_TIME = 15

  # The datetime of the scheduled appointment
  field :datetime, type: String
  # The status of the appointment
  field :status
  enumerize :status, in: %i[unassigned assigned completed], default: :unassigned
  # The estimated time to destination as provided by Google Maps
  field :est_time, type: Integer, default: 60

  # Embeds
  # There will be exactly 2 locations, [0] = pickup, [1] = dropoff
  embeds_many :locations, cascade_callbacks: true
  accepts_nested_attributes_for :locations

  # Belongs
  belongs_to :driver, optional: true
  belongs_to :patient, optional: true

  # Has
  has_many :comments

  # Callbacks
  # before_save :get_est_time
  # before_update :get_est_time
  after_update :send_updates

  def self.clean_past_appointments
    Appointment.each do |appt|
      appt.destroy if Time.parse(appt.datetime).past?
    end
  end

  # Calls the Google Maps API to retreive the estimated time for this ride.
  def get_est_time
    url = "https://maps.googleapis.com/maps/api/directions/json?origin=\
      #{locations[0].coordinates[0]},#{locations[0].coordinates[1]}\
      &destination=#{locations[1].coordinates[0]},\
      #{locations[1].coordinates[1]}&key=\
      #{Rails.application.credentials.gmap_geocode_api_kep}"
    response = HTTParty.get(url).parsed_response
    self.est_time = ((response['routes'].first['legs'].first['duration']['value']) / 60).round + BUFFER_TIME
  end

  # Sends updates via email (and if enabled also sends text message) to the
  # driver and the patient
  def send_updates
    if status == 1
      UserMailer.with(appt: self).ride_updated_email.deliver
      UserMailer.with(appt: self).ride_assigned_email.deliver
    end
  end
end
