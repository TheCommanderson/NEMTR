# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authorized, only: %i[index create new]

  def index
    if logged_in?
      case session[:login_type]
      when 'P'
        redirect_to patients_home_url
      when 'D'
        redirect_to drivers_home_url
      when 'A'
        redirect_to admins_home_url
      end
    end
  end

  def new; end

  def create
    @login_type = params[:login_type]

    case @login_type
    when 'Admin'
      @user = Admin.where(email: params[:email])[0]
    when 'Patient'
      @user = Patient.where(email: params[:email])[0]
    when 'Driver'
      @user = Driver.where(email: params[:email])[0]
    end
    if @user&.authenticate(params[:password])
      session[:user_id] = @user._id
      session[:login_type] = @login_type[0]
    else
      flash.notice = 'Incorrect Email or Password.'
    end
    redirect_to root_url
  end
end
