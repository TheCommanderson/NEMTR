class Location
  include Mongoid::Document
  include Mongoid::Geospatial

  field :location, type: Point

  field :addr1, type: String
  field :addr2, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: Integer
  embedded_in :Appointment
end
