class Preset
  include Mongoid::Document
  field :name, type: String
  field :addr1, type: String
  field :addr2, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: Integer
  field :home, type: Integer

  validates_presence_of :addr1, :city, :state, :zip

  embedded_in :Patient
end
