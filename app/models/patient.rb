class Patient
  include Mongoid::Document
  field :first_name, type: String
  field :middle_initial, type: String
  field :last_name, type: String
  field :phone, type: Integer
  field :email, type: String
  field :approved, type: Boolean
  
  belongs_to :admin
  has_many :appointments
end
