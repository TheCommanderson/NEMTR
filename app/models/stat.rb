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
  field :year, type: Integer
  # Number of drivers, patients and volunteers
  field :drivers, type: Integer
  field :patients, type: Integer
  field :volunteers, type: Integer

  # THIS FUNCTION SHOULD COLLECT AT THE BEGINNING OF THE MONTH AND THEN UPDATE
  # AS NECESSARY WHENEVER A FIELD UPDATES
  def self.collect
    s = Stat.where(month: (Time.current - 1.days).strftime('%B')).first
    s.patients = Patient.count
    s.drivers = Driver.count
    p = { patients: Patient.count, drivers: Driver.count, current: false }
    s.update_attributes(p)
    new_p = { rides: 0, reports: 0, date: Date.today.strftime('%B %Y'), drivers: 0, patients: 0 }
    next_stat = Stat.new(new_p)
    next_stat.save
  end
end
