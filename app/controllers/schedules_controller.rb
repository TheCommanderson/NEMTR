# frozen_string_literal: true

class SchedulesController < ApplicationController
  def index
    @driver = Driver.find(session[:user_id])
    @current_schedule = @driver.schedule.where(current: true).first
    @next_schedule = @driver.schedule.where(current: false).first
    @current_sch_readable = self.class.make_readable(@current_schedule)
    @next_sch_readable = self.class.make_readable(@next_schedule)
    @days_of_this_week = getDatesOfWeek(getMonday(DateTime.now))
    @days_of_next_week = getDatesOfWeek(getMonday((Time.current + 7.days).to_datetime))
  end
  
  def self.make_readable(schedule)
    @sch = {}
    days = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
    schedule.attributes.each do |name, val|
      next unless days.include? name

      if val[0..3] == val[5..8]
        @sch[name] = 'None'
      else
        ampm1 = 'AM'
        if val[0..1].to_i > 12
          h1 = val[0..1].to_i % 12
          ampm1 = 'PM'
        else
          h1 = val[0..1].to_i
        end
        ampm2 = 'AM'
        if val[5..6].to_i > 12
          h2 = val[5..6].to_i % 12
          ampm2 = 'PM'
        else
          h2 = val[5..6].to_i
        end
        day_str = h1.to_s + ':' + val[2..3] + ampm1 + ' to ' + h2.to_s + ':' + val[7..8] + ampm2
        @sch[name] = day_str
      end
    end
    return @sch
  end

  def new
    @driver = Driver.find(params[:driver_id])
    @schedule = @driver.schedule.new
  end

  def create
    @driver = Driver.find(params[:driver_id])
    @schedule = @driver.schedule.build(params[:schedule])
    @driver.save
  end

  def edit
    @driver = Driver.find(params[:driver_id])
    @schedule = @driver.schedule.where(id: params[:id]).first
    @days_of_week = if @schedule.current
                      getDatesOfWeek(getMonday(DateTime.now))
                    else
                      getDatesOfWeek(getMonday((Time.current + 7.days).to_datetime))
                    end
    @default_vals = {}
    @schedule.attributes.each do |name, val|
      next unless days.include? name

      @default_vals[name] = [val[0..1], val[2..3], val[5..6], val[7..8]]
    end
  end

  def update
    @driver = Driver.find(params[:driver_id])
    @schedule = @driver.schedule.where(id: params[:id]).first
    flash[:notice] = ''
    new_sch = {}
    days = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
    days.each do |day|
      day1 = (params[:schedule][day + '1(4i)']).to_s + (params[:schedule][day + '1(5i)']).to_s
      day2 = (params[:schedule][day + '2(4i)']).to_s + (params[:schedule][day + '2(5i)']).to_s
      if day1.to_i > day2.to_i
        flash[:notice] += day + ' was not updated, invalid time given.  '
        next
      end
      new_sch[day] = day1 + ' ' + day2
    end

    @schedule.update_attributes(new_sch)
    @debug_log = matching_alg
    redirect_to drivers_home_url
  end

  private

  def schedule_params
    params.require(:schedule).permit(:Monday, :Tuesday, :Wednesday, :Thursday, :Friday, :Saturday, :Sunday)
  end

  def days
    _days = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
  end

  def getDatesOfWeek(monday)
    _dates = []
    (0..6).each { |i| _dates.append((monday.to_time + i.days).strftime('%B %-d')) }
    _dates
  end
end
