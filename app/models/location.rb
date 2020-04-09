class Location
  include Mongoid::Document
  include Geocoder::Model::Mongoid

  field :addr1, type: String
  field :addr2, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: Integer

  field :full_street_address, type: String
  field :latitude, type: Float
  field :longitude, type: Float

  geocoded_by :full_street_address
  after_validation :geocode    
  embedded_in :Appointment
  before_create :generate_full_address

  protected
  def generate_full_address
    self.full_street_address = "#{addr1} #{addr2}, #{city}, #{state} #{zip}"
    puts self.full_street_address
  end
end
