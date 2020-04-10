class Admin
  include Mongoid::Document
  include ActiveModel::SecurePassword
  
  field :first_name, type: String
  field :middle_init, type: String
  field :last_name, type: String
  field :phone, type: Integer
  field :email, type: String
  field :auth_lvl, type: Integer
  field :host_org, type: String
  field :approved, type: Boolean
  field :password_digest, type: String
  
  has_secure_password
  has_many :drivers
  has_many :patients
end
