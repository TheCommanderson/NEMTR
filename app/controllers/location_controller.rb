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

  def update
    respond_to do |format|
      if @location.update(location_params)
        appt = Appointment.where('location._id' => @location.id).first
        status = appt.status
        appt.update(status: status)
        check_appt_update(appt)
        format.html { redirect_to root_url, notice: 'Location was successfully updated.'}
        # format.html { redirect_to @location, notice: 'Location was successfully created.' }
        format.json { render :show, status: :ok, location: @location }
      else
        format.html { render :edit }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

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
