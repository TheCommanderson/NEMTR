class Schedule
  include Mongoid::Document
  field :Monday, type: String
  field :Tuesday, type: String
  field :Wednesday, type: String
  field :Thursday, type: String
  field :Friday, type: String
  field :Saturday, type: String
  field :Sunday, type: String
  field :current, type: Boolean
  embedded_in :Driver
  
  def self.rollover
    Driver.each do |driver|
      next_sch = driver.schedule.where(:current => false).first
      cur_sch = driver.schedule.where(:current => true).first
      next_sch.update_attributes({:current => true})
      cur_sch.update_attributes({Monday: '0000 0000', Tuesday: '0000 0000', Wednesday: '0000 0000', Thursday: '0000 0000', Friday: '0000 0000', Saturday: '0000 0000', Sunday: '0000 0000', current: false})
    end
  end
end
