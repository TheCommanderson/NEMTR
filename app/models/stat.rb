class Stat
  include Mongoid::Document
  field :rides, type: Integer
  field :errors, type: Integer
  field :current, type: Boolean
  field :date, type: String
  field :drivers, type: Integer
  field :patients, type: Integer
end
