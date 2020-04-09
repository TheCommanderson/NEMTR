class Appointment
  include Mongoid::Document
  field :datetime, type: String
  field :status, type: Integer
  
  embeds_many :location, cascade_callbacks: true
  
  validates_associated :location
  
  accepts_nested_attributes_for :location
  
  belongs_to :driver, optional: true
  belongs_to :patient
end