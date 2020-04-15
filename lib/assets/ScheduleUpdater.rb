class ScheduleUpdater
    attr_accessor :schedules
    
    def rollover
      Driver.each do |driver|
        next_sch = driver.schedule.where(:current => false)
        cur_sch = driver.schedule.where(:current => true)
        next_sch.update_attributes({:current => true})
        cur_sch.update_attributes({Monday: '0000 0000', Tuesday: '0000 0000', Wednesday: '0000 0000', Thursday: '0000 0000', Friday: '0000 0000', Saturday: '0000 0000', Sunday: '0000 0000', current: false})
      end
    end
end