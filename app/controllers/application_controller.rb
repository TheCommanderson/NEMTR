class ApplicationController < ActionController::Base
    require 'date'
    require 'time'
    
    helper_method :current_user
    helper_method :logged_in?
    helper_method :sign
    before_action :authorized
    before_action :set_logger
    # Should return the current user or nil if not logged in
    def current_user
        _user = nil        
        case session[:login_type]
        when "P"
            _user = Patient.find(session[:user_id]) rescue nil
        when "D"
            _user = Driver.find(session[:user_id]) rescue nil
        when "A"
            _user = Admin.find(session[:user_id]) rescue nil
        else
            _user = nil
        end
    end
    
    def logged_in?
        !current_user.nil?
    end
    
    def logout
        session.delete(:login_type)
        session.delete(:user_id)
        redirect_to root_url, notice: "Successfully Logged Out"
    end
    
    def authorized
        redirect_to root_url, notice: "Please Log In." unless logged_in?
    end
    
    def sign(x)
        "++-"[x <=> 0]
    end
    
    def dt_format
       return '%Y-%m-%d %H:%M' 
    end
    
    def getMonday(date)
       wday = date.to_time.wday
       if wday == 0
           wday = 7
       end
       _monday = (date.to_time - (wday-1).days).to_datetime
       _monday
    end
    
    def valid_drivers(appt, cur)
        appt_start_time = DateTime.strptime(appt.datetime, dt_format).to_time.strftime("%H%M").to_i
        appt_end_time = (DateTime.strptime(appt.datetime, dt_format).to_time + appt.est_time.minutes).strftime("%H%M").to_i #est_time in minutes?
        @debug_log.append('appt start time: ' + appt_start_time.to_s)
        @debug_log.append('appt end time: ' + appt_end_time.to_s)
        drivers = []
        Driver.all.each do |driver|
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
                next
            end
            @debug_log.append('not blacklisted')
            
            # Checking if the appointment falls within the range of thier schedule
            driver_today_sch = driver.schedule.where(current: cur).first[DateTime.strptime(appt.datetime, dt_format).to_time.strftime("%A")]
            driver_today_time_start = driver_today_sch[0..3].to_i
            driver_today_time_end = driver_today_sch[5..8].to_i
            @debug_log.append('drivers start time for today: ' + driver_today_time_start.to_s)
            @debug_log.append('drivers end time for today: ' + driver_today_time_end.to_s)
            if driver_today_time_start == driver_today_time_end
                @debug_log.append('driver start time = driver end time')
                next
            end
            if (appt_start_time < driver_today_time_start)
                @debug_log.append('ride starts before driver starts today.')
                next
            elsif (appt_end_time > driver_today_time_end)
                @debug_log.append('ride ends after driver ends today.')
                next
            end
            @debug_log.append('schedule ok.')
            
            # Check if the driver has any conflicts with appointments
            @driver_apps = Appointment.where(driver_id: driver[:id])
            @bad = nil
            @driver_apps.each do |conflict|
                @debug_log.append('checking conflict with appt at ' + conflict.datetime)
                @bad = false
                conflict_start_time = DateTime.strptime(conflict.datetime, dt_format).to_time.strftime("%H%M").to_i
                conflict_end_time = (DateTime.strptime(conflict.datetime, dt_format).to_time + conflict.est_time.minutes).strftime("%H%M").to_i
                if sign(appt_start_time-conflict_start_time) != sign(appt_start_time-conflict_end_time) # appt starts in the middle of conlficting appt
                    @debug_log.append('appt starts in the middle of conflict')
                    @bad = true
                    break
                elsif sign(appt_end_time-conflict_start_time) != sign(appt_end_time-conflict_end_time) # appt ends in the middle of conflicting appt
                    @debug_log.append('appt ends in the middle of conflict')
                    @bad = true
                    break
                elsif appt_start_time <= conflict_start_time && appt_end_time >= conflict_end_time # conflict is contained completely inside appt
                    @debug_log.append('appt contains conflict')
                    @bad = true
                    break
                # NOTE: if appt is contained completely in the conflict then it will execute the first if statement
                end
            end
            # found a conflict, move to next driver
            if @bad
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
        if !@matchable_apps.exists?
            @debug_log.append('no valid appointments to match')
            return
        end

        @matchable_apps.each do |appt|
            @debug_log.append('appointment date: ' + appt.datetime)
            if ![this_monday.to_s[0..10], next_monday.to_s[0..10]].include? getMonday(DateTime.strptime(appt.datetime, dt_format)).to_s[0..10]
                @debug_log.append('appointment is not within the next 2 weeks')
                next
            end
            # TESTED TO HERE
            cur = (getMonday(DateTime.strptime(appt.datetime, dt_format)).to_s[0..10] == this_monday.to_s[0..10])
            @debug_log.append('is this appt this week? ' + cur.to_s)
            poss_drivers = valid_drivers(appt, cur)
            len = poss_drivers.to_a.length
            @debug_log.append(len.to_s + ' drivers found')
            if len == 0
                # HANDLE FAILURE
                next
            elsif len > 1
                rand_int = rand(len)
                driver = poss_drivers[rand_int]
            else
                driver = poss_drivers.first
            end
            @debug_log.append('appt assigned to ' + driver.first_name)
            new_atts = {status: 1, driver_id: driver[:id]}
            appt.update_attributes(new_atts)
        end
        return @debug_log
    end
    def set_logger
        if @debug_log.nil?
            @debug_log = ['start']
        end
    end
end