# frozen_string_literal: true

class ApplicationController < ActionController::Base
  require 'date'
  require 'time'

  helper_method :current_user
  helper_method :logged_in?
  helper_method :sign
  before_action :authorized
  before_action :set_logger

  # Helper returns current user or nil if not logged in
  def current_user
    _user = case session[:login_type]
            when 'P'
              begin
                  Patient.find(session[:user_id])
              rescue StandardError
                nil
                end
            when 'D'
              begin
                  Driver.find(session[:user_id])
              rescue StandardError
                nil
                end
            when 'A'
              begin
                  Admin.find(session[:user_id])
              rescue StandardError
                nil
                end
    end
  end

  # Helper to see if someone is logged in
  def logged_in?
    !current_user.nil?
  end

  # Logout function
  def logout
    session.delete(:login_type)
    session.delete(:user_id)
    redirect_to root_url, notice: 'Successfully Logged Out'
  end

  # Helper function to ensure user is authorized when they try to visit a page
  def authorized
    redirect_to root_url, notice: 'Please Log In.' unless logged_in?
  end

  # Helper returns the sign of the number provided
  def sign(x)
    '++-'[x <=> 0]
  end

  # Helper returns the string for datetime format storage in the database
  def dt_format
    '%Y-%m-%d %H:%M'
  end

  # Helper gets the monday of the week provided (7 is sunday because we begin our week on monday >:( )
  def getMonday(date)
    wday = date.to_time.wday
    wday = 7 if wday == 0
    _monday = (date.to_time - (wday - 1).days).to_datetime
    _monday
  end

  # ===================== MATCHING ALGORITHM STUFF ============================ #
  def check_appt_update(appt)
    if appt.status == 0
      log = matching_alg
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

  def check_conflicts(start_time, end_time, appt, dr)
    @driver_apps = Appointment.where(driver_id: dr)
    @driver_apps.each do |conflict|
      @debug_log.append('checking conflict with appt at ' + conflict.datetime)

      # Check if the date is the same
      appt_date = DateTime.strptime(appt.datetime, dt_format).strftime('%d%m%Y')
      conflict_date = DateTime.strptime(conflict.datetime, dt_format).strftime('%d%m%Y')
      if appt_date != conflict_date
        @debug_log.append('conflict is on a different day')
        next
      end

      # Check if there are conflicts with other appointments
      conflict_start_time = DateTime.strptime(conflict.datetime, dt_format).to_time.strftime('%H%M').to_i
      conflict_end_time = (DateTime.strptime(conflict.datetime, dt_format).to_time + conflict.est_time.minutes).strftime('%H%M').to_i
      if sign(start_time - conflict_start_time) != sign(start_time - conflict_end_time) # appt starts in the middle of conlficting appt
        @debug_log.append('appt starts in the middle of conflict')
        return false
      elsif sign(end_time - conflict_start_time) != sign(end_time - conflict_end_time) # appt ends in the middle of conflicting appt
        @debug_log.append('appt ends in the middle of conflict')
        return false
      elsif start_time <= conflict_start_time && end_time >= conflict_end_time # conflict is contained completely inside appt
        @debug_log.append('appt contains conflict')
        return false
        # NOTE: if appt is contained completely in the conflict then it will execute the first if statement
      end
    end
    true
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

  def matching_alg
    @debug_log.append('starting alg')
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
      UserMailer.with(appt: appt).ride_assigned_email.deliver
    end
    @debug_log
  end

  # ===================== MATCHING ENGINE STUFF END ============================ #
  def set_logger
    @debug_log = ['start'] if @debug_log.nil?
  end
end
