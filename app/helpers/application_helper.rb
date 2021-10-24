# frozen_string_literal: true

module ApplicationHelper
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

  # Helper returns the sign of the number provided
  def sign(x)
    '++-'[x <=> 0]
  end

  # Helper returns the string for datetime format storage in the database
  def dt_format
    '%Y-%m-%d %H:%M'
  end

  # Helper gets the monday of the week provided (7 is sunday because we begin our week on monday >:( )
  def get_monday(date)
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
end
