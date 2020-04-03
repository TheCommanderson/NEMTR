class SchedulesController < ApplicationController
  def index
    @driver = Driver.find(session[:user_id])
    @current_schedule = @driver.schedule.where(:current => true).first
    @current_json = @current_schedule.to_json
    @next_schedule = @driver.schedule.where(:current => false).first
    @next_json = @next_schedule.to_json
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
    redirect_to drivers_home_url
  end
  
  private
  def schedule_params
    params.require(:schedule).permit(:Monday, :Tuesday, :Wednesday, :Thursday, :Friday, :Saturday, :Sunday)
  end
end
