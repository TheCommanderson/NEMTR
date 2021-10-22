# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authorized
  before_action :redirect_to_home, only: %i[index new create about involved]

  # GET /sessions.json
  def index; end

  # GET /sessions/new
  def new
    @login_type = params[:login_type]
  end

  # POST /sessions.json
  def create
    user = User.where(email: params[:email]).first
    if user.present? && user.authenticate(params[:password])
      # sets up user.id sessions
      session[:user_id] = user.id
      session[:login_type] = user._type[0]
      flash[:info] = "Welcome, #{user.first_name}!"
      redirect_to root_url
    else
      flash.now[:danger] = 'Invalid email or password'

      render :new
    end
  end

  # GET /sessions/about
  def about; end

  # GET /sessions/involved
  def involved; end

  # DELETE /sessions
  def logout
    session.delete(:login_type)
    session.delete(:user_id)
    flash[:info] = 'Successfully logged out.'
    redirect_to root_url
  end

  def waiting; end

  private

  def redirect_to_home
    if logged_in?
      case session[:login_type]
      when 'D'
        redirect_to drivers_url
      when 'H'
        redirect_to healthcareadmins_url
      when 'P'
        redirect_to patients_url
      when 'S'
        redirect_to sysadmins_url
      when 'V'
        redirect_to volunteers_url
      end
    end
  end
end
