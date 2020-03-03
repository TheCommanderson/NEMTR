class Driver
  include Mongoid::Document
  field :first_name, type: String
  field :middle_init, type: String
  field :last_name, type: String
  field :phone, type: Integer
  field :email, type: String
  field :trained, type: Mongoid::Boolean
  embeds_one :car, class_name: "Car", dependent: :delete
  
  belongs_to :admin
  has_many :appointments
end