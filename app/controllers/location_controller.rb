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
  
  def edit
    @patient = Patient.find(params[:patient_id])
  end

  def update
  end

  private
  def set_appointment
    # @appointment = Appointment.find(params[:id])
  end
  def location_params
    params.require(:location).permit(
      :name, 
      :addr1, 
      :addr2, 
      :city, 
      :state, 
      :zip)
  end
end
