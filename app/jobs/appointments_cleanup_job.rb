# frozen_string_literal: true

class AppointmentsCleanupJob < ApplicationJob
  queue_as :default

  def perform
    Appointment.each do |appt|
      appt.destroy if Time.parse(appt.datetime).past?
    end
  end
end
