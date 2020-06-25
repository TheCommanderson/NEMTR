# frozen_string_literal: true

class UserMailer < ApplicationMailer
  default from: 'ride2health@uwbv.org'

  def ride_assigned_email
    @appointment = params[:appt]
    @driver = Driver.find(@appointment.driver_id)
    mail(to: @driver.email, subject: 'New Ride2Health Assignment')
  end

  def ride_created_email
    @appointment = params[:appt]
    @patient = Patient.find(@appointment.patient_id)
    mail(to: @patient.email, subject: 'Ride2Health Trip Confirmed')
  end
end
