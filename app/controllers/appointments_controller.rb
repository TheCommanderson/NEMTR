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

  def assign
    unless Appointment.where(id: params[:id]).blank?
      @appointment = Appointment.find(params[:id])
      @driver = Driver.find(params[:driver_id])
      appt_start_time = DateTime.strptime(@appointment.datetime, dt_format).to_time.strftime('%H%M').to_i
      appt_end_time = (DateTime.strptime(@appointment.datetime, dt_format).to_time + @appointment.est_time.minutes).strftime('%H%M').to_i
      if check_conflicts(appt_start_time, appt_end_time, @appointment, @driver[:id])
        new_atts = { status: 1, driver_id: @driver[:id] }
        @appointment.update_attributes(new_atts)
      else
        flash[:alert] = 'Could not assign appointment, conflict with existing appointment for this driver!'
      end
    end
    redirect_to admins_home_path
  end

  # GET /appointments/1
  # GET /appointments/1.json
  def show; end

  # GET /appointments/new
  def new
    @appointment = Appointment.new
    @patient = Patient.find(params[:patient_id])
    @preset = @patient.preset.where({ home: 1 })
    @preset = [] if params[:type] == 'clear'
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
        UserMailer.with(appt: @appointment).ride_created_email.deliver
        stats = Stat.where(current: true).first
        stats.update_attribute(:rides, stats.rides + 1)
        stats.save
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
    driver = appointment.driver_id
    patient = appointment.patient_id
    appointment.update_attribute(:status, 0)
    appointment.update_attribute(:driver_id, nil)
    redirect_back(fallback_location: root_path)
    current_user.add_to_set(blacklist: appointment._id)
    current_user.save
    if Time.parse(appointment.datetime) < 1.hour.from_now
      AdminMailer.with(driver: driver, patient: patient).short_cancel_email.deliver
    end
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
    unless Time.parse(@appointment.datetime).past?
      stats = Stat.where(current: true).first
      stats.update_attribute(:rides, stats.rides - 1)
      stats.save
    end
    @appointment.destroy
    respond_to do |format|
      format.html { redirect_to '/patients_home', notice: 'Appointment was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def report; end

  def sendReport
    appointment = Appointment.find(params[:id])
    driver = appointment.status == 1 ? Driver.find(appointment.driver_id) : nil
    patient = Patient.find(appointment.patient_id)
    reporter = current_user
    issue = params[:issue_text]
    if issue.empty?
      flash.alert = 'Issue cannot be blank.'
      redirect_back fallback_location: root_url and return
    end

    AdminMailer.with(driver: driver, patient: patient, reporter: reporter, issue: issue).issue_email.deliver
    redirect_to root_url, notice: 'Issue has been reported.' and return
    # STATS STUFF (*skeleton meme* thanks, but reconsider!!)
    # new_p = { rides: 0, reports: 0, current: true, date: Date.today.strftime('%B %Y'), drivers: 0, patients: 0 }
    # next_stat = Stat.new(new_p)
    # next_stat.save
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
