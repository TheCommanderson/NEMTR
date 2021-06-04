# frozen_string_literal: true

class PatientsController < ApplicationController
  before_action :set_patient, only: %i[show edit update destroy index comment append viewComments defaultAddress saveAddress]
  skip_before_action :authorized, only: %i[new create]
  before_action :patient_authorized, except: %i[new create edit update destroy comment append viewComments]
  before_action :admin_authorized, only: [:viewComments]
  # GET /patients
  def pending; end

  # GET /patients.json
  def index
    # TODO(spencer) change this to @patient in the index and remove this line
    @currentPatient = @patient
    @patients = Patient.all
    @appointments = Appointment
    @drivers = Driver.all
    @dt_format = dt_format
  end

  # GET /patients/1
  # GET /patients/1.json
  def show; end

  # GET /patients/new
  def new
    @patient = Patient.new
  end

  # GET /patients/1/edit
  def edit; end

  # POST /patients
  # POST /patients.json
  def create
    @patient = Patient.new(patient_params)
    @patient.approved = false unless @patient.approved

    respond_to do |format|
      if @patient.save
        AdminMailer.with(patient: @patient).new_patient_email.deliver
        format.html { redirect_to @patient, notice: 'Patient was successfully created.' }
        format.json { render :show, status: :created, location: @patient }
      else
        format.html { render :new }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /patients/1
  # PATCH/PUT /patients/1.json
  def update
    respond_to do |format|
      if @patient.update(patient_params)
        format.html { redirect_to @patient, notice: 'Update Successful!' }
        format.json { render :show, status: :ok, location: @patient }
      else
        format.html { render :edit }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /patients/1
  # DELETE /patients/1.json
  def destroy
    @patient.destroy
    respond_to do |format|
      format.html { redirect_to patients_url, notice: 'Patient was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def comment; end

  def append
    p_comment = params[:patient][:comment] + " [Comment by: #{current_user.first_name} #{current_user.last_name}]"
    @patient.add_to_set(comments: p_comment)
    @patient.save
    redirect_to root_path, notice: 'Thank you for your feedback!'
  end

  def viewComments; end

  def defaultAddress; end

  def saveAddress
    unless @patient.preset.where({ home: 1 }).empty?
      @current_default = @patient.preset.where({ home: 1 }).first
      @preset = @patient.preset.find(@current_default.id)
      @preset.destroy
    end

    if params[:type] != 'reset'
      addr1 = params[:preset][:addr1]
      addr2 = params[:preset][:addr2]
      city = params[:preset][:city]
      state = params[:preset][:state]
      zip = params[:preset][:zip]
      name = params[:preset][:name]

      @preset = @patient.preset.build(addr1: addr1, addr2: addr2, city: city, state: state, zip: zip, name: name, home: 1)
      @preset.save
      @patient.save
    end

    redirect_to patients_home_path
  end

  def self.day_schedules(schedules, day)
    @sch = []
    schedules.each do |sch|
      @sch << SchedulesController.make_readable(sch)[day]
    end

    num_schedules = @sch.length
    @sch.reject! { |val| val == 'None' }
    sorted_day = @sch.sort! { |a, b| a[a.index(':') + 3] <=> b[b.index(':') + 3] }

    sorted_day
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_patient
    @patient = Patient.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def patient_params
    params.require(:patient).permit(:first_name, :middle_initial, :last_name, :phone, :email, :host_org, :admin_id, :password, :search, :comment, preset_attributes: %i[name addr1 addr2 city state zip])
  end

  def patient_authorized
    redirect_to root_url unless session[:login_type] == 'P'
  end

  def admin_authorized
    redirect_to root_url unless session[:login_type] == 'A'
  end
end
