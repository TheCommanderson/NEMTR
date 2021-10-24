# frozen_string_literal: true

env :PATH, ENV['PATH']

# Use this file to easily define all of your cron jobs.
set :output, 'log/cron.log'

every :monday, at: '12:01 am' do
  runner 'Schedule.rollover'
end

every :monday, at: '12:05 am' do
  runner 'Driver.blacklist_reset'
end

every :monday, at: '12:10 am' do
  runner 'Appointment.clean_past_appointments'
end

every :month do
  runner 'Stat.collect'
end
