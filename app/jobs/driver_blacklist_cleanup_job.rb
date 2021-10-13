# frozen_string_literal: true

class DriverBlacklistCleanupJob < ApplicationJob
  queue_as :default

  def perform
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
end
