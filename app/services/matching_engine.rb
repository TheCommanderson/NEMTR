# frozen_string_literal: true

class MatchingEngine
  def self.check_appt_update(appt)
    if appt.status == 0
      matching_alg
    else
      driver = appt.driver_id
      atts = { status: 0, driver_id: nil }
      appt.update_attributes(atts)

      cur = (getMonday(DateTime.strptime(appt.datetime, dt_format)).to_s[0..10] == getMonday(DateTime.now).to_s[0..10])
      drivers = valid_drivers(appt, cur)
      if drivers.include? driver
        atts = { status: 1, driver_id: driver }
      else
        log = matching_alg
      end
    end
  end

  def valid_drivers(appt, cur)
    appt_start_time = DateTime.strptime(appt.datetime, dt_format).to_time.strftime('%H%M').to_i
    appt_end_time = (DateTime.strptime(appt.datetime, dt_format).to_time + appt.est_time.minutes).strftime('%H%M').to_i
    @debug_log.append('appt start time: ' + appt_start_time.to_s)
    @debug_log.append('appt end time: ' + appt_end_time.to_s)
    drivers = []

    Driver.where(trained: true).each do |driver|
      @debug_log.append('checking ' + driver.first_name)
      # Is this appointment on the driver blacklist?
      blacklisted = false
      driver.blacklist.each do |bl_appt|
        if bl_appt == appt._id
          blacklisted = true
          break
        end
      end
      if blacklisted
        @debug_log.append('This driver is blacklisted')
        next
      end
      @debug_log.append('not blacklisted')

      # Checking if the appointment falls within the range of thier schedule
      driver_today_sch = driver.schedule.where(current: cur).first[DateTime.strptime(appt.datetime, dt_format).to_time.strftime('%A')]
      driver_today_time_start = driver_today_sch[0..3].to_i
      driver_today_time_end = driver_today_sch[5..8].to_i
      @debug_log.append('drivers start time for today: ' + driver_today_time_start.to_s)
      @debug_log.append('drivers end time for today: ' + driver_today_time_end.to_s)

      if driver_today_time_start == driver_today_time_end
        @debug_log.append('Driver is not working this day.')
        next
      end
      if appt_start_time < driver_today_time_start
        @debug_log.append('ride starts before driver starts today.')
        next
      elsif appt_end_time > driver_today_time_end
        @debug_log.append('ride ends after driver ends today.')
        next
      end
      @debug_log.append('schedule ok.')

      # Check if the driver has any conflicts with appointments
      unless check_conflicts(appt_start_time, appt_end_time, appt, driver[:id])
        @debug_log.append('prior conflict')
        next
      end

      @debug_log.append('no issues.')
      drivers.push(driver)
    end
    drivers
  end

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
