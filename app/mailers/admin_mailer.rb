# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  default from: 'ride2health@uwbv.org'

  def new_patient_email
    @patient = params[:patient]
    emails = User.where(host_org: @patient.host_org, _type: 'Healthcareadmin').or(_type: 'Sysadmin').collect(&:email).join(',')

    mail(to: emails, subject: 'New Ride2Health Patient')
  end

  def new_driver_email
    @driver = params[:driver]
    emails = User.where(_type: 'Sysadmin').collect(&:email).join(',')

    mail(to: emails, subject: 'New Ride2Health Driver')
  end

  def new_volunteer_email
    @volunteer = params[:volunteer]
    emails = User.where(_type: 'Sysadmin').collect(&:email).join(',')
  end

  def new_healthcare_email
    @admin = params[:admin]
    emails = User.where(_type: 'Sysadmin').collect(&:email).join(',')

    mail(to: emails, subject: 'New Ride2Health Healthcare Account')
  end

  def short_cancel_email
    @driver = params[:driver]
    @patient = params[:patient]
    emails = User.where(_type: 'Sysadmin').or(_type: 'Volunteer').collect(&:email).join(',')

    mail(to: emails, subject: 'Ride2Health Driver Canceled an imminent trip!')
  end

  def ride_cancel_email
    @patient = params[:patient]
    @appointment = params[:appt]
    @driver = Driver.find(@appointment.driver_id)
    
    emails = User.where(_type: 'Sysadmin').or(_type: 'Volunteer').collect(&:email).join(',')
    mail(to: emails, subject: 'Ride2Health Trip Cancelled!').deliver

    if @driver.present? 
      mail(to: @driver.email, subject: 'A Ride2Health Trip Assigned to You Was Cancelled!').deliver
    end
    mail(to: @patient.email, subject: 'Your Ride2Health Trip Was Cancelled!')
  end

  def issue_email
    @reporter = params[:reporter]
    @driver = params[:driver]
    @patient = params[:patient]
    @issue = params[:issue]
    emails = User.where(_type: 'Sysadmin').collect(&:email).join(',')

    mail(to: emails, subject: 'Issue reported for a recent Ride2Health trip')
  end

  def password_reset_email
    @password = params[:password]
    mail(to: params[:user_email], subject: 'Ride2Health password reset')
  end
end
