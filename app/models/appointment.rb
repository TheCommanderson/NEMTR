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
  
  def self.clean_past_appointments
    Appointment.each do |appt|
      if DateTime.strptime(appt.datetime, '%Y-%m-%d %H:%M').to_date.past?
        appt.destroy
      end
    end
  end
end