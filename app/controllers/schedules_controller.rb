class SchedulesController < ApplicationController
  def index
    @driver = Driver.find(session[:user_id])
    @current_schedule = @driver.schedule[0]
    @next_schedule = @driver.schedule[1]
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
    @schedule.update_attributes(schedule_params)
    redirect_to drivers_home_url
  end
  
  private
  def schedule_params
    params.require(:schedule).permit(:Monday, :Tuesday, :Wednesday, :Thursday, :Friday, :Saturday, :Sunday)
  end
end
