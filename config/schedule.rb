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
every :sunday, at: "12:01 am" do
    runner "Schedule.rollover"
end
every :sunday, at: "12:01 am" do
    runner "Driver.blacklist_reset"
end

every 1.day, at: "12:01 am" do
    runner "Appointment.clean_past_appointments"
end

# Learn more: http://github.com/javan/whenever
