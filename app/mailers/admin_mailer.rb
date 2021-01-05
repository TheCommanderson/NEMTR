# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  default from: 'ride2health@uwbv.org'

  def new_patient_email
    @patient = params[:patient]
    @admin = Admin.where(host_org: @patient.host_org, auth_lvl: 2).first

    mail(to: @admin.email, subject: 'New Ride2Health Patient')
  end

  def new_driver_email
    @driver = params[:driver]
    emails = Admin.where(auth_lvl: 1).collect(&:email).join(',')

    mail(to: emails, subject: 'New Ride2Health Driver')
  end

  def new_admin_email
    @admin = params[:admin]
    emails = Admin.where(auth_lvl: 1).collect(&:email).join(',')

    mail(to: emails, subject: 'New Ride2Health Admin')
  end

  def short_cancel_email
    @driver = Driver.find(params[:driver])
    @patient = Patient.find(params[:patient])
    emails = Admin.where(auth_lvl: 1).collect(&:email).join(',')

    mail(to: emails, subject: 'Ride2Health Driver Canceled an imminent trip!')
  end

  def issue_email
    @reporter = params[:reporter]
    @driver = params[:driver]
    @patient = params[:patient]
    @issue = params[:issue]
    emails = Admin.where(auth_lvl: 1).collect(&:email).join(',')

    mail(to: emails, subject: 'Issue reported for a recent Ride2Health trip')
  end
end
