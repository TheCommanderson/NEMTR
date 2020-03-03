class LocationController < ApplicationController
  before_action :set_appointment, only: [:show, :edit, :update, :destroy]
    
  def new
    @appointment = Appointment.find(params[:appointment_id])
    @location = @appointment.location.new
  end
  
  def create
    @appointment = Appointment.find(params[:appointment_id]) 
    @location = @appointment.location.new(params[:location])
  end
end
