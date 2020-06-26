# frozen_string_literal: true

class Appointment
  include Mongoid::Document
  field :datetime, type: String
  field :status, type: Integer
  field :est_time, type: Integer

  embeds_many :location, cascade_callbacks: true

  validates_associated :location

  accepts_nested_attributes_for :location

  belongs_to :driver, optional: true
  belongs_to :patient, optional: true

  before_save :get_est_time
  before_update :get_est_time
  after_update :email_updates

  def self.clean_past_appointments
    Appointment.each do |appt|
      appt.destroy if DateTime.strptime(appt.datetime, '%Y-%m-%d %H:%M').to_date.past?
    end
  end

  def get_est_time
    url = 'https://maps.googleapis.com/maps/api/directions/json?origin=' + location[0].coordinates[0].to_s + ',' + location[0].coordinates[1].to_s + '&destination=' + location[1].coordinates[0].to_s + ',' + location[1].coordinates[1].to_s + '&key=' + Rails.application.credentials.gmap_geocode_api_kep
    response = HTTParty.get(url).parsed_response
    self.est_time = ((response['routes'].first['legs'].first['duration']['value']) / 60).round + 15 # BUFFER TIME
  end

  def email_updates
    if status == 1
      UserMailer.with(appt: self).ride_updated_email.deliver
      UserMailer.with(appt: self).ride_assigned_email.deliver
    end
  end
end
