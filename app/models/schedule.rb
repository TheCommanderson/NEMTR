class Schedule
  include Mongoid::Document
  field :Monday, type: String
  field :Tuesday, type: String
  field :Wednesday, type: String
  field :Thursday, type: String
  field :Friday, type: String
  field :Saturday, type: String
  field :Sunday, type: String
  field :Current, type: Boolean
  embedded_in :Driver
end
