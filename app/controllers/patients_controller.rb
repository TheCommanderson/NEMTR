class PatientsController < ApplicationController
  before_action :set_patient, only: [:show, :edit, :update, :destroy]
  skip_before_action :authorized, only: [:new, :create]
  before_action :patient_authorized, except: [:new, :create, :edit, :update, :destroy, :comment, :append, :viewComments]
  before_action :admin_authorized, only: [:viewComments]
  # GET /patients
  def pending
  end
  # GET /patients.json
  def index
    @currentPatient = Patient.find(session[:user_id])
    @patients = Patient.all
    @appointments = Appointment
    @drivers = Driver.all
  end

  # GET /patients/1
  # GET /patients/1.json
  def show
  end

  # GET /patients/new
  def new
    @patient = Patient.new
  end

  # GET /patients/1/edit
  def edit
  end

  # POST /patients
  # POST /patients.json
  def create
    @patient = Patient.new(patient_params)
    if (!@patient.approved)
      @patient.approved = false
    end

    respond_to do |format|
      if @patient.save
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
        format.html { redirect_to @patient, notice: 'Patient was successfully updated.' }
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
      format.html { redirect_to patients_url, notice: 'Patient was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def comment
    @patient = Patient.find(params[:id])
  end

  def append
    patient = Patient.find(params[:id])
    p_comment = params[:patient][:comment] + " [Comment by: #{current_user.first_name} #{current_user.last_name}]"
    patient.add_to_set(comments: p_comment)
    patient.save
    redirect_to root_path, notice: "Thank you for your feedback!"
  end

  def viewComments
    @patient = Patient.find(params[:id])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_patient
      @patient = Patient.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def patient_params
      params.require(:patient).permit(:first_name, :middle_initial, :last_name, :phone, :email, :host_org, :admin_id, :password, :search, :comment, preset_attributes: [:name, :addr1, :addr2, :city, :state, :zip])
    end

    def patient_authorized
      redirect_to root_url unless session[:login_type] == 'P'
    end
    def admin_authorized
      redirect_to root_url unless session[:login_type] == 'A'
    end
end
