# frozen_string_literal: true

class Appointment
  include Mongoid::Document
  extend Enumerize

  BUFFER_TIME = 15

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
  before_save :get_est_time
  after_update :send_updates

  def self.clean_past_appointments
    Appointment.each do |appt|
      appt.destroy if Time.parse(appt.datetime).past?
    end
  end

  def check_appt_update
    if status == 0
      logger.info "#{id} is now unassigned, re-running matching algorithm."
      MatchingEngine.matching_alg
    else
      cur = (getMonday(DateTime.strptime(datetime, dt_format)).to_s[0..10] == getMonday(DateTime.now).to_s[0..10])
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
    logger.info "appt start time: #{appt_start_time}, end time: #{appt_end_time}"
    drivers = []

    Driver.where(trained: true).each do |driver|
      # Is this appointment on the driver blacklist?
      blacklisted = false
      driver.blacklist.each do |bl_appt|
        if bl_appt == appt._id
          blacklisted = true
          break
        end
      end
      if blacklisted
        logger.info "#{driver.id} is blacklisted"
        next
      end

      # Checking if the appointment falls within the range of thier schedule
      driver_today_sch = driver.schedule.where(current: cur).first[DateTime.strptime(appt.datetime, dt_format).to_time.strftime('%A')]
      driver_today_time_start = driver_today_sch[0..3].to_i
      driver_today_time_end = driver_today_sch[5..8].to_i

      if driver_today_time_start == driver_today_time_end
        logger.info "#{driver.id} is not on call on this day."
        next
      end
      if appt_start_time < driver_today_time_start
        logger.info "Ride starts before #{driver.id} starts today."
        next
      elsif appt_end_time > driver_today_time_end
        logger.info "ride ends after #{driver.id} ends today."
        next
      end

      # Check if the driver has any conflicts with appointments
      if driver.has_conflict(appt)
        logger.info "#{driver.id} has a prior conflict."
        next
      end

      logger.info "#{driver.id} is eligible for #{appt.id}"
      drivers.push(driver)
    end
    drivers
  end

  # Calls the Google Maps API to retreive the estimated time for this ride.
  def get_est_time
    url = "https://maps.googleapis.com/maps/api/directions/json?origin=\
      #{locations[0].coordinates[0]},#{locations[0].coordinates[1]}\
      &destination=#{locations[1].coordinates[0]},\
      #{locations[1].coordinates[1]}&key=\
      #{Rails.application.credentials.gmap_geocode_api_kep}"
    response = HTTParty.get(url).parsed_response
    self.est_time = ((response['routes'].first['legs'].first['duration']['value']) / 60).round + BUFFER_TIME
  end

  # Sends updates via email (and if enabled also sends text message) to the
  # driver and the patient
  def send_updates
    if status == 1
      UserMailer.with(appt: self).ride_updated_email.deliver
      UserMailer.with(appt: self).ride_assigned_email.deliver
    end
  end
end
