class Appointment
  include Mongoid::Document
  field :datetime, type: String
  field :status, type: Integer
  
  belongs_to :driver
  belongs_to :patient
end
