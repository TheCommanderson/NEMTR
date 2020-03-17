class Location
  include Mongoid::Document
  field :addr1, type: String
  field :addr2, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: Integer
  
  embedded_in :appointment, inverse_of: :location
end
