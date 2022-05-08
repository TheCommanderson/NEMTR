# frozen_string_literal: true

# Class that tracks stats per month for the ride2health team to keep track of.
class Stat
  include Mongoid::Document
  # The number of rides given this month
  field :rides, type: Integer
  # The number of reports filed this month
  field :reports, type: Integer
  field :reported_appointments, type: Array, default: true
  # Month and Year
  field :month, type: String
  field :year, type: String
  # Number of drivers, patients and volunteers
  field :drivers, type: Integer
  field :patients, type: Integer
  field :volunteers, type: Integer

  # THIS FUNCTION SHOULD COLLECT AT THE BEGINNING OF THE MONTH AND THEN UPDATE
  # AS NECESSARY WHENEVER A FIELD UPDATES
  def self.collect
    begin
      s = Stat.where(month: (Time.current - 1.days).strftime('%B'), year: (Time.current - 1.days).strftime('%Y')).first
      p = { patients: Patient.count, drivers: Driver.count, volunteers: Volunteer.count }
      s.update_attributes(p)
    rescue StandardError
      new_current_p = {
        rides: 0,
        reports: 0,
        month: Date.today.strftime('%B'),
        year: Date.today.strftime('%Y'),
        drivers: Driver.count,
        patients: Patient.count,
        volunteers: Volunteer.count
      }
      s = Stat.new(new_current_p)
      s.save
    end
    new_p = {
      rides: 0,
      reports: 0,
      month: Date.today.strftime('%B'),
      year: Date.today.strftime('%Y'),
      drivers: 0,
      patients: 0,
      volunteers: 0
    }
    next_stat = Stat.new(new_p)
    next_stat.save
  end
end
