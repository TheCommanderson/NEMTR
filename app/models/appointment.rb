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
  
  def self.clean_past_appointments
    Appointment.each do |appt|
      if DateTime.strptime(appt.datetime, '%Y-%m-%d %H:%M').to_date.past?
        appt.destroy
      end
    end
  end

  def get_est_time
    url="http://maps.googleapis.com/maps/api/directions/json?origin=" + self.location[0].coordinates[0] + "," + self.location[0].coordinates[1] + "&destination=" + self.location[1].coordinates[0] + "," + self.location[1].coordinates[1] + "&key=" + Rails.application.credentials.gmap_geocode_api_kep
    response = HTTParty.get(url)
    self.est_time = 60
  end
end