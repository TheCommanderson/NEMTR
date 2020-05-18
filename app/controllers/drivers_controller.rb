class DriversController < ApplicationController
  before_action :set_driver, only: [:show, :edit, :update, :destroy]
  skip_before_action :authorized, only: [:new, :create]
  before_action :driver_authorized, except: [:new, :create]
  # GET /drivers
  # GET /drivers.json

  def index
    @logged_in_driver = Driver.find(session[:user_id])
    @drivers = Driver.all
    @patients = Patient.all
    @appointments = Appointment.where(status: 0).sort_by { |appt| [ appt.datetime ] }
    @dt_format = dt_format
  end

 # GET /drivers
  def pending
    @logged_in_driver = Driver.find(session[:user_id])
    @drivers = Driver.all
    @patients = Patient.all
    @appointments = Appointment.all.sort_by { |appt| [ appt.status, appt.datetime ] }
  end

  # GET /drivers/1
  # GET /drivers/1.json
  def show

  end

  # GET /drivers/new
  def new
    @driver = Driver.new
  end

  def test
    @debug_log = matching_alg
  end

  def claim
    appointment = Appointment.find(params[:appt])
    driver = Driver.find(session[:user_id])
    appt_start_time = DateTime.strptime(appointment.datetime, dt_format).to_time.strftime("%H%M").to_i
    appt_end_time = (DateTime.strptime(appointment.datetime, dt_format).to_time + appointment.est_time.minutes).strftime("%H%M").to_i
    if check_conflicts(appt_start_time, appt_end_time, appointment, driver[:id])
      new_atts = {status: 1, driver_id: driver[:id]}
      appointment.update_attributes(new_atts)
    else
      flash[:alert] = 'Could not claim appointment, conflict with existing appointment!'
    end
    redirect_to root_url
  end

  # GET /drivers/1/edit
  def edit
  end

  # POST /drivers
  # POST /drivers.json
  def create
    sch1 = {Monday: '0000 0000', Tuesday: '0000 0000', Wednesday: '0000 0000', Thursday: '0000 0000', Friday: '0000 0000', Saturday: '0000 0000', Sunday: '0000 0000', current: true}
    sch2 = {Monday: '0000 0000', Tuesday: '0000 0000', Wednesday: '0000 0000', Thursday: '0000 0000', Friday: '0000 0000', Saturday: '0000 0000', Sunday: '0000 0000', current: false}

    @driver = Driver.new(driver_params)
    @sch1 = @driver.schedule.build(sch1)
    @sch2 = @driver.schedule.build(sch2)

    if (!@driver.trained)
      @driver.trained = false
    end

    respond_to do |format|
      if @driver.save
        format.html { redirect_to @driver, notice: 'Driver was successfully created.' }
        format.json { render :show, status: :created, location: @driver }
      else
        format.html { render :new }
        format.json { render json: @driver.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /drivers/1
  # PATCH/PUT /drivers/1.json
  def update
    respond_to do |format|
      if @driver.update(driver_params)
        format.html { redirect_to @driver, notice: 'Driver was successfully updated.' }
        format.json { render :show, status: :ok, location: @driver }
      else
        format.html { render :edit }
        format.json { render json: @driver.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /drivers/1
  # DELETE /drivers/1.json
  def destroy
    @driver.destroy
    respond_to do |format|
      format.html { redirect_to drivers_url, notice: 'Driver was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_driver
      @driver = Driver.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def driver_params
      params.require(:driver).permit(:first_name, :middle_init, :last_name, :phone, :email, :trained, :admin_id, :password, schedule_attributes: [:Monday, :Tuesday, :Wednesday, :Thursday, :Friday, :Saturday, :Sunday, :current])
    end

    def driver_authorized
      redirect_to root_url unless session[:login_type] == 'D'
    end
end
