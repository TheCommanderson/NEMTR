class Admin
  include Mongoid::Document
  field :first_name, type: String
  field :middle_init, type: String
  field :last_name, type: String
  field :phone, type: Integer
  field :email, type: String
  field :auth_lvl, type: Integer
  field :host_org, type: String
  
  has_many :drivers
  has_many :patients
end
