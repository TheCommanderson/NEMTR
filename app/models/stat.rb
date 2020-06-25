# frozen_string_literal: true

class Stat
  include Mongoid::Document
  field :rides, type: Integer
  field :errors, type: Integer
  field :current, type: Boolean
  field :date, type: String
  field :drivers, type: Integer
  field :patients, type: Integer
end

def self.collect
  Stat.find_by(current: true) do |s|
    s.patients = Patient.count
    s.drivers = Driver.count
    s.current = false
  end
  params = { rides: 0, errors: 0, current: true, date: Date.today.strftime('%B %Y'), drivers: 0, patients: 0 }
  next_stat = Stat.new(params)
end
