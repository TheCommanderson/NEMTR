class Admin
  include Mongoid::Document
  field :first_name, type: String
  field :middle_initial, type: String
  field :last_name, type: String
  field :phone, type: Integer
  field :email, type: String
  field :auth_lvl, type: Integer
  field :host_org, type: String
end
