class ApplicationController < ActionController::Base
    require 'date'
    
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
        !session[:login_type].nil?
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
    
    def valid_drivers(appt)
        dt_format = '%Y-%m-%d %k:%l:%M'
        appt_start_time = DateTime.strptime(appt.datetime, dt_format)
        appt_end_time = (appt_start_time.to_time + appt.est_time.minutes).to_datetime
        drivers = []
        Driver.all.each do |driver|
            @driver_apps = Appointment.where(driver_id: driver[:id])
            driver_today_sch = driver.schedule.where(current: true).first[Time.now.strftime("%A")]
            
        end
    end
    
    def matching_alg
       @matchable_apps = Appointment.where(status: -1)
       if !@matchable_apps.exists?
           return
       end
       @matchable_apps.each do |appt|
          poss_drivers = valid_drivers(appt)
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
    end
end