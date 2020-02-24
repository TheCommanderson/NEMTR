class Appointment
  include Mongoid::Document
  field :patient, type: String
  field :driver, type: String
  field :date_time, type: Time
  field :location, type: String
  field :status, type: String
end
