# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  default from: 'ride2health@uwbv.org'

  def new_patient_email
    @patient = params[:patient]
    @admin = Admin.where(host_org: @patient.host_org, auth_lvl: 2).first

    mail(to: @admin.email, subject: 'New Ride2Health Patient')
  end

  def short_cancel_email
    @driver = Driver.find(params[:driver])
    @patient = Patient.find(params[:patient])
    emails = Admin.where(auth_lvl: 1).collect(&:email).join(',')
    mail(to: emails, subject: 'Ride2Health Driver Canceled an imminent trip!')
  end
end
