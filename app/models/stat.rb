# frozen_string_literal: true

class Stat
  include Mongoid::Document
  field :rides, type: Integer
  field :reports, type: Integer
  field :current, type: Boolean
  field :date, type: String
  field :drivers, type: Integer
  field :patients, type: Integer

  def self.collect
    s = Stat.where(current: true).first
    s.patients = Patient.count
    s.drivers = Driver.count
    s.current = false
    p = { patients: Patient.count, drivers: Driver.count, current: false }
    s.update_attributes(p)
    new_p = { rides: 0, reports: 0, current: true, date: Date.today.strftime('%B %Y'), drivers: 0, patients: 0 }
    next_stat = Stat.new(new_p)
    next_stat.save
  end
end
