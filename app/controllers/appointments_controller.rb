# frozen_string_literal: true

class AppointmentsController < ApplicationController
  before_action :set_appointment, only: %i[show edit update destroy]

  # GET /appointments
  # GET /appointments.json
  def index
    @appointments = Appointment.all.sort_by { |appt| [appt.status, appt.datetime] }
    @drivers = Driver.all
    @patients = Patient.all
  end

  # GET /appointments/1
  # GET /appointments/1.json
  def show; end

  # GET /appointments/new
  def new
    @appointment = Appointment.new
    @patient = Patient.find(params[:patient_id])
  end

  # GET /appointments/1/edit
  def edit; end

  # POST /appointments
  # POST /appointments.json
  def create
    patient = Patient.find(params[:appointment][:patient_id])
    loc = patient.preset.find(params[:loc_select])
    loc_hash = { name: loc.name, addr1: loc.addr1, addr2: loc.addr2, city: loc.city, state: loc.state, zip: loc.zip }
    @appt_parms = appointment_params
    @appt_parms['datetime'] = params[:appointment]['dt(1i)'] + '-' + params[:appointment]['dt(2i)'] + '-' + params[:appointment]['dt(3i)'] + ' ' + params[:appointment]['dt(4i)'] + ':' + params[:appointment]['dt(5i)']
    if @appt_parms[:location_attributes]['0'][:name] == 'tmp'
      @appt_parms[:location_attributes]['0'].merge! loc_hash
    else
      @appt_parms[:location_attributes]['1'].merge! loc_hash
    end

    @appointment = Appointment.new(@appt_parms)
    respond_to do |format|
      if @appointment.save
        format.html { redirect_to root_url }
        # format.html { redirect_to @appointment, notice: 'Appointment was successfully created.' }
        format.json { render :show, status: :created, location: @appointment }
      else
        format.html { redirect_to root_url, notice: 'Error with appointment.  Please ensure all fields are filled out.' }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
    @debug_log = matching_alg
  end

  def cancel
    appointment = Appointment.find(params[:id])
    appointment.update_attribute(:status, 0)
    appointment.update_attribute(:driver_id, nil)
    redirect_back(fallback_location: root_path)
    current_user.add_to_set(blacklist: appointment._id)
    current_user.save
  end

  # PATCH/PUT /appointments/1
  # PATCH/PUT /appointments/1.json
  def update
    respond_to do |format|
      @appt_parms = appointment_params
      @appt_parms['datetime'] = params[:appointment]['dt(1i)'] + '-' + params[:appointment]['dt(2i)'] + '-' + params[:appointment]['dt(3i)'] + ' ' + params[:appointment]['dt(4i)'] + ':' + params[:appointment]['dt(5i)']
      if @appointment.update(@appt_parms)
        check_appt_update(@appointment)
        format.html { redirect_to '/patients_home', notice: 'Appointment was successfully updated.' }
        # format.html { redirect_to @appointment, notice: 'Appointment was successfully created.' }
        format.json { render :show, status: :ok, location: @appointment }
      else
        format.html { render :edit }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /appointments/1
  # DELETE /appointments/1.json
  def destroy
    @appointment.destroy
    respond_to do |format|
      format.html { redirect_to '/patients_home', notice: 'Appointment was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def appointment_params
    params.require(:appointment).permit(
      :patient_id,
      :driver_id,
      :datetime,
      :status,
      :est_time,
      location_attributes: %i[name addr1 addr2 city state zip]
    )
  end
end
