# frozen_string_literal: true

class MatchingEngine
  def self.matching_alg
    logger.debug 'starting matching algorithm'
    this_monday = getMonday(DateTime.now)
    next_monday = getMonday((Time.now + 7.days).to_datetime)
    logger.debug "This monday: #{this_monday}, Next monday: #{next_monday}"
    @matchable_apps = Appointment.where(status: 0)
    if @matchable_apps.empty?
      logger.warning 'no valid appointments to match, why did this start?'
      return
    end

    # For each appointment without a driver execute this code
    @matchable_apps.each do |appt|
      logger.info "matching #{appt.id}"
      # Check if this appointment is within the next two weeks
      appt_monday = getMonday(DateTime.strptime(appt.datetime, dt_format)).to_s[0..10]
      unless [this_monday.to_s[0..10], next_monday.to_s[0..10]].include? appt_monday
        logger.info "#{appt.id} is not within the next 2 weeks"
        next
      end

      # Check for all valid drivers and assign one randomly to this appointment
      cur = (appt_monday == this_monday.to_s[0..10])
      logger.info "#{appt.id} is this week: #{cur}"
      valid_drivers = appt.valid_drivers(cur)
      len = valid_drivers.to_a.length
      logger.info "#{len} drivers found"
      if len == 0
        next
      elsif len > 1
        rand_int = rand(len)
        driver = valid_drivers[rand_int]
      else
        driver = valid_drivers.first
      end

      # Assign the driver
      new_atts = { status: 1, driver_id: driver[:id] }
      appt.update_attributes(new_atts)
      logger.info "#{appt.id} assigned to #{driver.id}"
    end
  end
end
