class SchedulesController < ApplicationController
  def index
    @driver = Driver.find(session[:user_id])
    @current_schedule = @driver.schedule.where(:current => true).first
    @next_schedule = @driver.schedule.where(:current => false).first
    @current_sch_readable = {}
    @next_sch_readable = {}
    
    @current_schedule.attributes.each do |name, val|
      next if not days.include? name
      if val[0..3] == val[5..8]
        @current_sch_readable[name] = "None"
      else
        day_str = val[0..1] + ":" + val[2..3] + " to " + val[5..6] + ":" + val[7..8]
        @current_sch_readable[name] = day_str
      end
    end
    
    @next_schedule.attributes.each do |name, val|
      next if not days.include? name
      if val[0..3] == val[5..8]
        @next_sch_readable[name] = "None"
      else
        day_str = val[0..1] + ":" + val[2..3] + " to " + val[5..6] + ":" + val[7..8]
        @next_sch_readable[name] = day_str
      end
    end
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
    @schedule = @driver.schedule.where(:id => params[:id]).first
    if @schedule.current
      @monday_date = getMonday(DateTime.now).to_date
    else
      @monday_date = getMonday((Time.now + 7.days).to_datetime)
    end
    @default_vals = {}
    @schedule.attributes.each do |name, val|
      next if not days.include? name
      @default_vals[name] = [val[0..1], val[2..3], val[5..6], val[7..8]]
    end
  end
  
  def update
    @driver = Driver.find(params[:driver_id])
    @schedule = @driver.schedule.where(:id => params[:id]).first
    
    new_sch = {}
    days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    days.each do |day|
      day1 = (params[:schedule][day+"1(4i)"]).to_s + (params[:schedule][day+"1(5i)"]).to_s
      day2 = (params[:schedule][day+"2(4i)"]).to_s + (params[:schedule][day+"2(5i)"]).to_s
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
    _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
  end
end
