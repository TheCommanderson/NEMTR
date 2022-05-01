# frozen_string_literal: true

class AppointmentsController < ApplicationController
  before_action :set_appointment, only: %i[show edit update destroy assign]
  def index; end

  # GET /appointments/1 or /appointments/1.json
  def show
    @patient = Patient.find(@appointment.patient_id)
  end

  # GET /appointments/new
  def new
    @appointment = Appointment.new
    @patient = Patient.find(params[:patient_id])
    @preset = @patient.locations.where(home: true).first unless @patient.locations.where(home: true).empty?
    @locations = @patient.locations.where(preset: true)
  end

  # GET /appointments/1/edit
  def edit; end

  # POST /appointments
  def create
    patient = Patient.find(params[:appointment][:patient_id])
    l = if params.key?('loc-select-to')
          patient.locations.find(params['loc-select-to'])
        else
          patient.locations.find(params['loc-select-from'])
        end
    location_hash = { name: l.name, addr1: l.addr1, addr2: l.addr2, city: l.city, state: l.state, zip: l.zip, preset: l.preset }
    appt_params = appointment_params
    appt_params['datetime'] = "#{params[:appointment]['dt(1i)']}-#{params[:appointment]['dt(2i)']}-#{params[:appointment]['dt(3i)']} #{params[:appointment]['dt(4i)']}:#{params[:appointment]['dt(5i)']}"

    ride_time = Time.parse(appt_params['datetime'])
    if ride_time.past?
      flash[:info] = 'Oops!  You tried to book a ride in the past!  Please retry with a date in the future.'
      redirect_to new_appointment_path(patient_id: patient.id)
    end
    if ride_time.saturday? || ride_time.sunday?
      flash[:info] = 'Oops!  Cannot schedule a weekend ride.'
      redirect_to new_appointment_path(patient_id: patient.id)
    end
    if ride_time.between(
      Time.local(ride_time.year, ride_time.month, ride_time.day, 8),
      Time.local(ride_time.year, ride_time.month, ride_time.day, 4, 45)
    )
      flash[:info] = 'Oops!  Can only schedule a ride between 8AM and 4:45PM.'
      redirect_to new_appointment_path(patient_id: patient.id)
    end

    if appt_params[:locations_attributes]['0'][:name] == 'tmp'
      appt_params[:locations_attributes]['0'].merge! location_hash
    else
      appt_params[:locations_attributes]['1'].merge! location_hash
    end
    @appointment = Appointment.new(appt_params)

    respond_to do |format|
      if @appointment.save
        MatchingEngine.matching_alg
        UserMailer.with(appt: @appointment).ride_created_email.deliver
        flash[:info] = 'Appointment was successfully booked!'
        format.html { redirect_to root_url }
      else
        format.html { render :new }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /appointments/1 or /appointments/1.json
  def update
    appt_params = appointment_params
    appt_params['datetime'] = "#{params[:appointment]['dt(1i)']}-#{params[:appointment]['dt(2i)']}-#{params[:appointment]['dt(3i)']} #{params[:appointment]['dt(4i)']}:#{params[:appointment]['dt(5i)']}"
    respond_to do |format|
      if @appointment.update(appt_params)
        @appointment.check_appt_update
        flash[:info] = 'Successfully changed the date and time of appointment.'
        format.html { redirect_to @appointment }
        format.json { render :show, status: :ok, location: @appointment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /appointments/1
  # DELETE /appointments/1.json
  def destroy
    @appointment.destroy
    respond_to do |format|
      flash[:danger] = 'Ride was successfully cancelled.'
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  def assign
    @drivers = Driver.where(trained: true).select { |d| d.has_conflict(@appointment) }
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
      locations_attributes: %i[name addr1 addr2 city state zip]
    )
  end
end
