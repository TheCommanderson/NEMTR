# frozen_string_literal: true

class MatchingEngine
  def self.matching_alg
    .append('starting alg')
    this_monday = getMonday(DateTime.now)
    next_monday = getMonday((Time.now + 7.days).to_datetime)
    @debug_log.append('this monday: ' + this_monday.to_s)
    @debug_log.append('next monday: ' + next_monday.to_s)
    @matchable_apps = Appointment.where(status: 0)
    unless @matchable_apps.exists?
      @debug_log.append('no valid appointments to match')
      return
    end

    # For each appointment without a driver execute this code
    @matchable_apps.each do |appt|
      @debug_log.append('appointment date: ' + appt.datetime)
      # Check if this appointment is within the next two weeks
      appt_monday = getMonday(DateTime.strptime(appt.datetime, dt_format)).to_s[0..10]
      unless [this_monday.to_s[0..10], next_monday.to_s[0..10]].include? appt_monday
        @debug_log.append('appointment is not within the next 2 weeks')
        next
      end

      # Check for all valid drivers and assign one randomly to this appointment
      cur = (appt_monday == this_monday.to_s[0..10])
      @debug_log.append('is this appt this week? ' + cur.to_s)
      poss_drivers = valid_drivers(appt, cur)
      len = poss_drivers.to_a.length
      @debug_log.append(len.to_s + ' drivers found')
      if len == 0
        next
      elsif len > 1
        rand_int = rand(len)
        driver = poss_drivers[rand_int]
      else
        driver = poss_drivers.first
      end

      # Assign the driver
      @debug_log.append('appt assigned to ' + driver.first_name)
      new_atts = { status: 1, driver_id: driver[:id] }
      appt.update_attributes(new_atts)
    end
  end
end
