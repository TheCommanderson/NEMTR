class Patient
  include Mongoid::Document
  field :first_name, type: String
  field :middle_initial, type: String
  field :last_name, type: String
  field :phone, type: Integer
  field :email, type: String
  field :approver, type: String
  field :location, type: String
end
