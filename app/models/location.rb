# frozen_string_literal: true

class Location
  include Mongoid::Document
  include Geocoder::Model::Mongoid

  # Nickname of the address
  field :name, type: String
  # Address fields
  field :addr1, type: String
  field :addr2, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: Integer
  # Information retrieved by Geocoder
  field :address, type: String
  field :coordinates, type: Array
  # This field is only used when the location belongs to a patient
  field :home, type: Boolean, default: false
  # This field is only used when the location is on the approved list of presets
  field :preset, type: Boolean, default: false

  validates_presence_of :addr1, :city, :state
  validates_length_of :zip, minimum: 5, maximum: 5

  # Embeds
  embedded_in :Appointment
  embedded_in :Patient

  # Callbacks
  before_create :generate_full_address

  protected

  def generate_full_address
    addr = "#{addr1} #{addr2}, #{city}, #{state} #{zip}"
    result = Geocoder.search(addr)
    logger.debug "The address is: #{addr}"
    logger.debug "The result is: #{result}"
    if result.first.nil?
      logger.warn('Geocoder returned nothing')
    else
      self.coordinates = result.first.coordinates
      self.address = result.first.address
    end
  end
end
