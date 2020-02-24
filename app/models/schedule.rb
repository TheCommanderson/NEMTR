class Schedule
  include Mongoid::Document
  field :driver, type: String
  field :monday, type: String
  field :tuesday, type: String
  field :wednesday, type: String
  field :thursday, type: String
  field :friday, type: String
  field :saturday, type: String
  field :sunday, type: String
end
