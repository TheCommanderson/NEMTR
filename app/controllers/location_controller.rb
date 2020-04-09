class LocationController < ApplicationController
  before_action :set_appointment
    
  def new
    @appointment = Appointment.find(params[:appointment_id])
    @location = @appointment.location.new
  end
  
  def create
    @appointment = Appointment.find(params[:appointment_id]) 
    @location = @appointment.location.build(params[:location])
    @appointment.save
  end

  private
  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def generate_address
    self.full_street_address = "#{addr1} #{addr2}, #{city}, #{state} #{zip}"
  end
end
