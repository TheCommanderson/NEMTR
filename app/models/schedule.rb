# frozen_string_literal: true

class Schedule
  include Mongoid::Document

  # Schedule keeps a string of 'XXXX YYYY' for each day of the week, denoting
  # the start and end time of their volunteer hours for that day.  Yes, this is
  # hacky and no, I don't want to change it.
  field :Monday, type: String
  field :Tuesday, type: String
  field :Wednesday, type: String
  field :Thursday, type: String
  field :Friday, type: String
  field :Saturday, type: String
  field :Sunday, type: String
  field :current, type: Boolean

  # Embeds
  embedded_in :Driver

  # Each week the 'next week' schedule (non-current) needs to rollover and
  # become the current schedule, and the next week schedule needs to be wiped
  # TODO(spencer) instead of wiping, optionally use the same schedule using the 'keep_schedule' attr in Driver.rb
  def self.rollover
    Driver.each do |driver|
      next_sch = driver.schedules.where(current: false).first
      cur_sch = driver.schedules.where(current: true).first
      next_sch.update_attributes({ current: true })
      cur_sch.update_attributes({ Monday: '0000 0000', Tuesday: '0000 0000', Wednesday: '0000 0000', Thursday: '0000 0000', Friday: '0000 0000', Saturday: '0000 0000', Sunday: '0000 0000', current: false })
    end
  end
end
