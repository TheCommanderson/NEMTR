class Driver
  include Mongoid::Document
  field :first_name, type: String
  field :middle_initial, type: String
  field :last_name, type: String
  field :phone, type: Integer
  field :email, type: String
  field :approver, type: String
  field :car_make, type: String
  field :car_model, type: String
  field :car_plate, type: String
  field :car_year, type: Integer
  field :trained, type: Mongoid::Boolean
end
