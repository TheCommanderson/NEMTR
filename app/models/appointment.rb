class Appointment
  include Mongoid::Document
  field :datetime, type: String
  field :status, type: Integer
  embeds_one :location, class_name: "Location"
  
  belongs_to :driver
  belongs_to :patient
end
