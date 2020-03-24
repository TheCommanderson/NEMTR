class ApplicationController < ActionController::Base
    helper_method :current_user
    helper_method :logged_in?
    
    # Should return the current user or nil if not logged in
    def current_user
        case session[:login_type]
        when "P"
            _user = Patient.find(session[:user_id])
        when "D"
            _user = Driver.find(session[:user_id])
        when "A"
            _user = Admin.find(session[:user_id])
            _user = nil
        end
    end
    
    def logged_in?
        !session[:login_type].nil?
    end
    def logout
        session.delete(:login_type)
        session.delete(:user_id)
        redirect_to root_url
    end
end
