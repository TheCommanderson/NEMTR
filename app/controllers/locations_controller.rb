# frozen_string_literal: true

class LocationsController < ApplicationController
  before_action :set_location, only: %i[show]

  # GET /locations or /locations.json
  def index
    @locations = if params[:patient_id]
                   Patient.find(params[:patient_id]).locations.where(home: false)
                 else
                   Location.all
                 end
    @patient = Patient.find(params[:patient_id]) if params.key?(:patient_id)
  end

  # GET /locations/1 or /locations/1.json
  def show; end

  # GET /locations/new
  def new
    @patient = Patient.find(params[:patient_id])
    @location = if params[:patient_id]
                  @patient.locations.new
                else
                  Location.new
                end
  end

  # GET /locations/1/edit
  def edit
    @appointment = Appointment.find(params[:appointment_id])
    @location = @appointment.locations.find(params[:id])
    @patient = Patient.find(@appointment.patient_id)
  end

  # POST /locations or /locations.json
  def create
    patient = Patient.find(params[:patient_id])
    patient.locations.where(home: true).each(&:delete) if params[:location].key?(:home) && params[:location][:home]

    @location = if params[:patient_id]
                  patient.locations.new(location_params)
                else
                  Location.new(location_params)
                end
    respond_to do |format|
      if @location.save
        flash[:info] = 'Location was successfully saved!'
        format.html { redirect_to patient_locations_path(patient) }
        format.json { render :show, status: :created, location: @location }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locations/1 or /locations/1.json
  def update
    if params[:appt_id]
      appointment = Appointment.find(params[:appt_id])
      @location = appointment.locations.find(params[:id])
      if params[:location][:name] == 'tmp'
        patient = Patient.find(appointment.patient_id)
        l = patient.locations.find(params['loc-select'])
        l_params = { name: l.name, addr1: l.addr1, addr2: l.addr2, city: l.city, state: l.state, zip: l.zip, preset: l.preset }
      else
        l_params = location_params
      end
    end
    respond_to do |format|
      if @location.update(l_params)
        flash[:info] = 'Update was successful!'
        format.html { redirect_to root_url }
        format.json { render :show, status: :ok, location: @location }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1 or /locations/1.json
  def destroy
    patient = Patient.find(params[:patient_id])
    @location = if params[:patient_id]
                  patient.locations.find(params[:id])
                else
                  Location.find(params[:id])
                end
    @location.destroy
    respond_to do |format|
      format.html { redirect_to request.headers['HTTP_REFERER'], notice: 'location was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_location
    @location = Location.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def location_params
    params.require(:location).permit(
      :addr1, :addr2, :city, :state, :zip, :name, :home, :preset
    )
  end
end
