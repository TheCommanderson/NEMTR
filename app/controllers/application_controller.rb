class ApplicationController < ActionController::Base
    require 'date'
    require 'time'
    
    helper_method :current_user
    helper_method :logged_in?
    helper_method :sign
    before_action :authorized
    # Should return the current user or nil if not logged in
    def current_user
        case session[:login_type]
        when "P"
            _user = Patient.find(session[:user_id])
        when "D"
            _user = Driver.find(session[:user_id])
        when "A"
            _user = Admin.find(session[:user_id])
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
        drivers = []
        Driver.all.each do |driver|
            
            # Is this appointment on the driver blacklist?
            if driver.blacklist.empty?
                next
            elsif driver.blacklist.where(appointment_id: appt[:id]).exists?
                next
            end
            
            # Check if the driver has any conflicts with appointments
            @driver_apps = Appointment.where(driver_id: driver[:id])
            @bad = nil
            @driver_apps.each do |dr_appt|
                @bad = false
                dr_appt_start_time = DateTime.strptime(dr_appt.datetime, dt_format).to_time.strftime("%H%M").to_i
                dr_appt_end_time = (DateTime.strptime(dr_appt.datetime, dt_format).to_time + dr_appt.est_time.minutes).strftime("%H%M").to_i
                if sign(appt_start_time-dr_appt_start_time) != sign(appt_start_time-dr_appt_end_time) # appt starts in the middle of conlficting appt
                    @bad = true
                    break
                elsif sign(appt_end_time-dr_appt_start_time) != sign(appt_end_time-dr_appt_end_time) # appt ends in the middle of conflicting appt
                    @bad = true
                    break
                elsif appt_start_time <= dr_appt_start_time && appt_end_time >= dr_appt_end_time # conflict is contained completely inside appt
                    @bad = true
                    break
                # NOTE: if appt is contained completely in the conflict then it will execute the first if statement
                end
            end
            if @bad
               next 
            end
            
            # Checking if the appointment falls within the range of thier schedule
            driver_today_sch = driver.schedule.where(current: cur).first[Time.now.strftime("%A")]
            driver_today_time_start = driver_today_sch[0..3].to_i
            driver_today_time_end = driver_today_sch[5..8].to_i
            
            if !(driver_today_time_start <= appt_start_time && appt_start_time <= driver_today_time_end)
                next
            elsif !(driver_today_time_start <= appt_end_time && appt_end_time <= driver_today_time_end)
                next
            end
            
            drivers.push(driver)
        end
    end
    
    def matching_alg
        this_monday = getMonday(DateTime.now)
        next_monday = getMonday((Time.now + 7.days).to_datetime)
        @matchable_apps = Appointment.where(status: 0)
        str = this_monday.to_s + ", " + next_monday.to_s + "\n"
        if !@matchable_apps.exists?
            return
        end

        @matchable_apps.each do |appt|
            if ![this_monday.to_s[0..10], next_monday.to_s[0..10]].include? getMonday(DateTime.strptime(appt.datetime, dt_format)).to_s[0..10]
                next
            end
            # TESTED TO HERE
            cur = getMonday(DateTime.strptime(appt.datetime, dt_format)) == this_monday
            poss_drivers = valid_drivers(appt, cur)
            str = poss_drivers
            len = poss_drivers.to_a.length
            if len == 0
                # HANDLE FAILURE
                next
            elsif len > 1
                rand_int = rand(len)
                driver = poss_drivers[rand_int]
            else
                driver = poss_drivers.first
            end
            new_atts = {status: 1, driver_id: driver[:id]}
            appt.update_attributes(new_atts)
        end
        return str
    end
end