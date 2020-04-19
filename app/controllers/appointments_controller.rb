class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [:show, :edit, :update, :destroy]

  # GET /appointments
  # GET /appointments.json
  def index
    @appointments = Appointment.all
    @drivers = Driver.all
    @patients = Patient.all
  end

  # GET /appointments/1
  # GET /appointments/1.json
  def show
  end

  # GET /appointments/new
  def new
    @appointment = Appointment.new
  end

  # GET /appointments/1/edit
  def edit
    
  end

  # POST /appointments
  # POST /appointments.json
  def create
    @appt_parms = appointment_params
    @appt_parms['datetime'] =params[:appointment]['dt(1i)'] + '-' + params[:appointment]['dt(2i)'] + '-' + params[:appointment]['dt(3i)'] + ' ' + params[:appointment]['dt(4i)'] + ':' + params[:appointment]['dt(5i)']
    @appointment = Appointment.new(@appt_parms)
    @debug_log = matching_alg
    respond_to do |format|
      if @appointment.save
        format.html { redirect_to "/patients_home"}
        # format.html { redirect_to @appointment, notice: 'Appointment was successfully created.' }
        format.json { render :show, status: :created, location: @appointment }
      else
        format.html { render :new }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
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
        format.html { redirect_to "/patients_home", notice: 'Appointment was successfully updated.'}
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
      format.html { redirect_to "/patients_home", notice: 'Appointment was successfully destroyed.' }
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
        location_attributes: [:name, :addr1, :addr2, :city, :state, :zip])
    end
end
