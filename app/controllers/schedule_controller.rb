class ScheduleController < ApplicationController
  before_action :set_appointment
  
  def index
    
  end
  
  def new
    @driver = Driver.find(params[:driver_id])
    @schedule = @driver.schedule.new
  end
  
  def create
    @driver = Appointment.find(params[:driver_id]) 
    @schedule = @driver.schedule.build(params[:schedule])
    @schedule.save
  end
  
  def update
  
  end
  
  private
  def set_appointment
    @appointment = Appointment.find(params[:id])
  end
end
