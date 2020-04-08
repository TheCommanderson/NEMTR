class Driver
  include Mongoid::Document
  include ActiveModel::SecurePassword
  
  field :first_name, type: String
  field :middle_init, type: String
  field :last_name, type: String
  field :phone, type: Integer
  field :email, type: String
  field :trained, type: Mongoid::Boolean
  field :blacklist, type: Array, default: []
  field :password_digest, type: String
  
  embeds_many :schedule
  accepts_nested_attributes_for :schedule
  
  has_secure_password
  belongs_to :admin
  has_many :appointments
end