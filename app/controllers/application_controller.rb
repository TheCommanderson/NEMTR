# frozen_string_literal: true

class ApplicationController < ActionController::Base
  require 'date'
  require 'time'

  helper_method :current_user
  helper_method :logged_in?
  helper_method :sign
  helper_method :all_host_orgs
  helper_method :dt_format
  helper_method :user_type
  helper_method :build_gmap_url

  rescue_from ::StandardError, with: :handle_standard_error

  before_action :authorized

  add_flash_types :danger, :info

  # =============== HELPER FUNCTIONS ================== #
  # Helper returns current user or nil if not logged in
  def current_user
    User.find(session[:user_id])
  rescue StandardError
    nil
  end

  # Helper to see if someone is logged in
  def logged_in?
    !current_user.nil?
  end

  # Helper function to ensure user is authorized when they try to visit a page
  def authorized
    unless logged_in?
      flash[:info] = 'Please log in.'
      redirect_to root_url
    end
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

  def all_host_orgs
    Admin.all.map(&:host_orgs).compact.flatten.uniq
  end

  def build_gmap_url(_location_1, _location_2)
    q = {
      api: '1',
      origin: _location_1.address,
      destination: _location_2.address,
      travelmode: 'driving'
    }
    URI::HTTPS.build(host: 'www.google.com', path: '/maps/dir/', query: q.to_query).to_s
  end

  # ===================== RESCUE =================== #
  def handle_standard_error(e)
    logger.error("encountered error: #{e}")
  end
end
