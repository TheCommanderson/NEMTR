# frozen_string_literal: true

class Driver < User
  include Mongoid::Document

  # Has the driver been trained?
  field :trained, type: Boolean, default: false
  # Driver's car information
  field :car_make, type: String
  field :car_model, type: String
  field :car_color, type: String
  field :car_license_plate, type: String
  # If a driver declines an appt, this appt ID is entered into a blacklist to
  # prevent this driver from being reassigned the appointment
  field :blacklist, type: Array, default: []
  field :keep_schedule, type: Boolean, default: false

  before_create :create_schedule

  # Embeds
  # A driver will have exactly 2 schedules, since they are able to set their
  # schedule up to 2 weeks out
  embeds_many :schedules
  accepts_nested_attributes_for :schedules

  # Belongs
  belongs_to :sysadmin, optional: true

  # Has
  has_many :appointments

  # Cleanup method for all driver blacklists that will find and remove any
  # appointments that are now in the past for every driver.
  def self.blacklist_reset
    Driver.each do |driver|
      to_del = []
      driver.blacklist.each do |bl|
        appt = begin
                 Appointment.find(bl)
               rescue StandardError
                 nil
               end
        if appt.nil?
          to_del.append(bl)
        elsif Time.parse(appt.datetime).past?
          to_del.append(bl)
        end
      end
      to_del.each do |d|
        driver.blacklist.delete(d)
      end
      driver.save
    end
  end

  # returns true if conflict exists, else returns false
  def has_conflict(appt)
    @driver_apps = Appointment.where(driver_id: id)
    @driver_apps.each do |conflict|
      # Check if the date is the same
      appt_date = DateTime.strptime(appt.datetime, dt_format).strftime('%d%m%Y')
      conflict_date = DateTime.strptime(conflict.datetime, dt_format).strftime('%d%m%Y')
      next if appt_date != conflict_date

      # Check if there are conflicts with other appointments
      conflict_start_time = DateTime.strptime(conflict.datetime, dt_format).to_time.strftime('%H%M').to_i
      conflict_end_time = (DateTime.strptime(conflict.datetime, dt_format).to_time + conflict.est_time.minutes).strftime('%H%M').to_i
      if sign(start_time - conflict_start_time) != sign(start_time - conflict_end_time) # appt starts in the middle of conlficting appt
        return true
      elsif sign(end_time - conflict_start_time) != sign(end_time - conflict_end_time) # appt ends in the middle of conflicting appt
        return true
      elsif start_time <= conflict_start_time && end_time >= conflict_end_time # conflict is contained completely inside appt
        return true
        # NOTE: if appt is contained completely in the conflict then it will execute the first if statement
      end
    end
    false
  end

  private

  # helper to initialize new drvier schedules.
  def create_schedule
    first_schedule = { Monday: '0000 0000',
                       Tuesday: '0000 0000',
                       Wednesday: '0000 0000',
                       Thursday: '0000 0000',
                       Friday: '0000 0000',
                       Saturday: '0000 0000',
                       Sunday: '0000 0000',
                       current: true }
    second_schedule = { Monday: '0000 0000',
                        Tuesday: '0000 0000',
                        Wednesday: '0000 0000',
                        Thursday: '0000 0000',
                        Friday: '0000 0000',
                        Saturday: '0000 0000',
                        Sunday: '0000 0000',
                        current: false }
    schedules.build(first_schedule)
    schedules.build(second_schedule)
  end
end
