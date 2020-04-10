class LocationController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy]
  def index
  end

  def show
  end


  def new
    @appointment = Appointment.find(params[:appointment_id])
    @location = @appointment.location.new
  end
  
  def edit
  end

  def create
    @appointment = Appointment.find(params[:appointment_id]) 
    @location = @appointment.location.build(params[:location])
    @appointment.save
  end

<<<<<<< HEAD
=======
  def update
    # @appointment = Appointment.find(params[:appointment_id])
    # # Find out if the passed location is pick-up or destination
    # # [0] is pick-up location
    # # [1] is destination
    # if params[:id] == @appointment.location[0]["_id"].to_s
    #   @location = @appointment.location[0]
    # else
    #   @location = @appointment.location[1]
    # end
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to "/patients_home", notice: 'Location was successfully updated.'}
        # format.html { redirect_to @location, notice: 'Location was successfully created.' }
        format.json { render :show, status: :ok, location: @location }
      else
        format.html { render :edit }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

>>>>>>> e1527e2ab73735094f9d19748e4d1fe3b1b921b6
  private
  def set_location
    @appointment = Appointment.find(params[:appointment_id])
    # Find out if the passed location is pick-up or destination
    # [0] is pick-up location
    # [1] is destination
    if params[:id] == @appointment.location[0]["_id"].to_s
      @location = @appointment.location[0]
    else
      @location = @appointment.location[1]
    end
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

  def generate_address
    self.full_street_address = "#{addr1} #{addr2}, #{city}, #{state} #{zip}"
  end
end
