class SchedulesController < ApplicationController
  def index
    
  end
  
  def new
    @driver = Driver.find(params[:driver_id])
    @schedule = @driver.schedule.new
  end
  
  def create
    @driver = Driver.find(params[:driver_id]) 
    @schedule = @driver.schedule.build(params[:schedule])
    @schedule.save
  end
  
  def update
  
  end
  
  private
end
