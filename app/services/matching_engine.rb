# frozen_string_literal: true

class MatchingEngine
  extend ApplicationHelper

  def self.matching_alg
    Rails.logger.debug 'starting matching algorithm'
    this_monday = get_monday(DateTime.now)
    next_monday = get_monday((Time.now + 7.days).to_datetime)
    Rails.logger.debug "This monday: #{this_monday}, Next monday: #{next_monday}"
    @matchable_apps = Appointment.where(status: :unassigned)
    if @matchable_apps.empty?
      Rails.logger.warn 'no valid appointments to match, why did this start?'
      return
    end

    # For each appointment without a driver execute this code
    @matchable_apps.each do |appt|
      Rails.logger.info "matching #{appt.id}"
      # Check if this appointment is within the next two weeks
      appt_monday = get_monday(DateTime.strptime(appt.datetime, dt_format)).to_s[0..10]
      unless [this_monday.to_s[0..10], next_monday.to_s[0..10]].include? appt_monday
        Rails.logger.info "#{appt.id} is not within the next 2 weeks.  Appt monday is: #{appt_monday}."
        next
      end

      # Check for all valid drivers and assign one randomly to this appointment
      cur = (appt_monday == this_monday.to_s[0..10])
      Rails.logger.info "#{appt.id} is this week: #{cur}"
      valid_drivers = appt.valid_drivers(cur)
      len = valid_drivers.to_a.length
      Rails.logger.info "#{len} drivers found"
      if len == 0
        next
      elsif len > 1
        rand_int = rand(len)
        driver = valid_drivers[rand_int]
      else
        driver = valid_drivers.first
      end

      # Assign the driver
      new_atts = { status: :assigned, driver_id: driver[:id] }
      appt.update_attributes(new_atts)
      Rails.logger.info "#{appt.id} assigned to #{driver.id}"
      UserMailer.with(appt: appt).ride_assigned_email.deliver
    end
  end
end
