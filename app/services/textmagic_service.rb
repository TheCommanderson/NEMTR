# frozen_string_literal: true

class TextmagicService
  cattr_reader :textmagic_client, instance_accessor: false do
    Textmagic::REST::Client.new 'ride2health', Rails.application.credentials.textmagic_api_key
  end

  def self.send_ride_confirmation(phone, datetime)
    text = "You've been assigned a new ride on Ride2Health! " \
           "Ride date and time: #{datetime}.  Please check your email for " \
           'full details of the ride.'
    args = { phones: "1#{phone}", text: text }
    textmagic_client.messages.create(args)
  end

  def self.send_ride_cancelled(driver, datetime)
    text = "A Ride2Health ride has just been cancelled by #{driver}. " \
           "Ride date and time: #{datetime}.  Please check ride2health.org " \
           'for full details.'
    phones = User.where(_type: 'Sysadmin').collect { |a| "1#{a.phone}" }.join(',')
    args = { phones: phones, text: text }
    textmagic_client.messages.create(args)
  end
end
