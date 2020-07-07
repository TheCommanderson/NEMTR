# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
set :output, 'log/cron.log'
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end
every :monday, at: '12:01 am' do
  runner 'Schedule.rollover'
end

every :monday, at: '12:05 am' do
  runner 'Driver.blacklist_reset'
end

every :monday, at: '12:10 am' do
  runner 'Appointment.clean_past_appointments'
end

# Learn more: http://github.com/javan/whenever
