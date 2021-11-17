# frozen_string_literal: true

class UserMailer < ApplicationMailer
  default from: 'ride2health@uwbv.org'

  def ride_assigned_email
    @appointment = params[:appt]
    @driver = User.find(@appointment.driver_id)
    mail(to: @driver.email, subject: 'New Ride2Health Assignment')
  end

  def ride_created_email
    @appointment = params[:appt]
    @patient = User.find(@appointment.patient_id)
    mail(to: @patient.email, subject: 'Ride2Health Trip Confirmed')
  end

  def ride_updated_email
    @appointment = params[:appt]
    @patient = User.find(@appointment.patient_id)
    @driver = User.find(@appointment.driver_id)
    mail(to: @patient.email, subject: 'Ride2Health Trip Updated')
  end

  def patient_approved_email
    @patient = params[:patient]
    mail(to: @patient.email, subject: 'Your Ride2Health Account was Approved')
end
