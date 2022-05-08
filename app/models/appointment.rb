# frozen_string_literal: true

class Appointment
  include Mongoid::Document
  extend Enumerize
  include ApplicationHelper

  # The datetime of the scheduled appointment
  field :datetime, type: String
  # The status of the appointment
  field :status
  enumerize :status, in: %i[unassigned assigned completed], default: :unassigned
  # The estimated time to destination as provided by Google Maps
  field :est_time, type: Integer, default: 60

  # Embeds
  # There will be exactly 2 locations, [0] = pickup, [1] = dropoff
  embeds_many :locations, cascade_callbacks: true
  accepts_nested_attributes_for :locations

  # Belongs
  belongs_to :driver, optional: true
  belongs_to :patient, optional: true

  # Has
  has_many :comments

  # Callbacks
  after_save :get_est_time
  after_update :send_updates

  def self.clean_past_appointments
    s = Stat.where(month: (Time.current - 1.days).strftime('%B')).first
    ride_count = 0
    Appointment.each do |appt|
      if Time.parse(appt.datetime).past?
        appt.destroy
        ride_count += 1
      end
      s.update_attribute(:rides, s.rides + ride_count)
    end
  end

  def check_appt_update
    if status.unassigned?
      logger.info "#{id} is now unassigned, re-running matching algorithm."
      MatchingEngine.matching_alg
    else
      cur = (get_monday(DateTime.strptime(datetime, dt_format)).to_s[0..10] == get_monday(DateTime.now).to_s[0..10])
      drivers = valid_drivers(cur)
      unless drivers.include? driver_id
        atts = { status: 0, driver_id: nil }
        update_attributes(atts)
        logger.info "#{driver_id} now has a conflict, re-runnning matching algorithm"
        MatchingEngine.matching_alg
      end
    end
  end

  def valid_drivers(cur)
    logger.info "checking valid drivers for #{id}"
    appt_start_time = DateTime.strptime(datetime, dt_format).to_time.strftime('%H%M').to_i
    appt_end_time = (DateTime.strptime(datetime, dt_format).to_time + est_time.minutes).strftime('%H%M').to_i
    logger.info "appt date: #{datetime}, appt start time: #{appt_start_time}, end time: #{appt_end_time}"
    drivers = []

    Driver.where(trained: true).each do |driver|
      # Is this appointment on the driver blacklist?
      blacklisted = false
      driver.blacklist.each do |bl_appt|
        if bl_appt == _id
          blacklisted = true
          break
        end
      end
      if blacklisted
        logger.info "#{driver.id} is blacklisted"
        next
      end

      # Checking if the appointment falls within the range of their schedule
      driver_today_sch = driver.schedules.where(current: cur).first[DateTime.strptime(datetime, dt_format).to_time.strftime('%A')]
      driver_today_time_start = driver_today_sch[0..3].to_i
      driver_today_time_end = driver_today_sch[5..8].to_i

      if driver_today_time_start == driver_today_time_end
        logger.info "#{driver.id} is not on call on this day."
        next
      elsif appt_start_time < driver_today_time_start
        logger.info "Ride starts before #{driver.id} starts today."
        next
      elsif appt_end_time > driver_today_time_end
        logger.info "ride ends after #{driver.id} ends today."
        next
      end

      # Check if the driver has any conflicts with appointments
      if driver.has_conflict(_id)
        logger.info "#{driver.id} has a prior conflict."
        next
      end

      logger.info "#{driver.id} is eligible for #{_id}"
      drivers.push(driver)
    end
    drivers
  end

  # Calls the Google Maps API to retreive the estimated time for this ride.
  def get_est_time
    if locations[0].coordinates.nil? || locations[1].coordinates.nil?
      logger.warn 'Coordinates did not exist for these locations, returning default est_time'
      self.est_time = 15
      return
    end
    url = "https://maps.googleapis.com/maps/api/directions/json?origin=\
      #{locations[0].coordinates[0]},#{locations[0].coordinates[1]}\
      &destination=#{locations[1].coordinates[0]},\
      #{locations[1].coordinates[1]}&key=\
      #{Rails.application.credentials.google_maps_key}"
    response = HTTParty.get(url).parsed_response
    if response.nil?
      self.est_time = 0
      logger.warn "Google Maps API returned nothing for est time.  Request URL: #{url}"
    else
      est_time_min = response['routes'].first['legs'].first['duration']['value'] / 60
      buffer_time = est_time_min * 0.1
      self.est_time = (est_time_min + buffer_time).round
    end
  end

  # Sends updates via email (and if enabled also sends text message) to the
  # driver and the patient
  def send_updates
    UserMailer.with(appt: self).ride_updated_email.deliver if status.assigned?
  end
end
