class Appointment
  include Mongoid::Document
  field :patient, type: String
  field :driver, type: String
  field :datetime, type: String
  field :status, type: Integer
  field :destination, type: String
  embeds_one :location, class_name: "Location"
  
  # belongs_to :driver
  # belongs_to :patient
end
