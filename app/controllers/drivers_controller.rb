# frozen_string_literal: true

class DriversController < UsersController
  skip_before_action :authorized, only: %i[create new]
  before_action :set_driver, only: %i[show edit update destroy approve assign]

  # GET /drivers or /drivers.json
  def index
    @driver = current_user
    @appointments = Appointment.where(status: :unassigned)
    @driver_appointments = Appointment.where(driver_id: current_user.id)
  end

  # GET /drivers/1 or /drivers/1.json
  def show; end

  # GET /drivers/new
  def new
    @driver = Driver.new
  end

  # GET /drivers/1/edit
  def edit; end

  # POST /drivers or /drivers.json
  def create
    @driver = Driver.new(driver_params)

    respond_to do |format|
      begin
        if @driver.save
          format.html { redirect_to @driver, notice: 'driver was successfully created.' }
          format.json { render :show, status: :created, location: @driver }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @driver.errors, status: :unprocessable_entity }
        end
      rescue ArgumentError
        flash.now[:danger] = 'Please ensure all fields are filled in.'
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /drivers/1 or /drivers/1.json
  # This function is only used to update car information, user info is edited
  # using the users_controller.rb
  def update
    respond_to do |format|
      if @driver.update(driver_params)
        flash[:info] = 'Info was successfully updated!'
        format.html { redirect_to @driver }
        format.json { render :show, status: :ok, location: @driver }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @driver.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /drivers/1 or /drivers/1.json
  def destroy
    @driver.destroy
    respond_to do |format|
      format.html { redirect_to root_url, notice: 'driver was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def approve
    @driver.update_attribute(:trained, !@driver.trained)
    if @driver.trained && @driver.update_attribute(:sysadmin, current_user)
      flash[:info] = 'Approved!'
    elsif !@driver.trained && @driver.unset(:sysadmin)
      flash[:info] = 'Driver unapproved successfully.'
    else
      flash[:danger] = 'There was an error (un)approving this driver, please try again.'
    end
    redirect_to root_url
  end

  def assign
    appointment = Appointment.find(params[:appointment_id])
    if appointment.status.unassigned?
      if appointment.update({ status: :assigned, driver_id: params[:id] })
        flash[:info] = 'Ride was successfully assigned!'
      else
        flash[:danger] = "Oops, that ride couldn't be assigned."
      end
    else
      if appointment.has_attribute?(:driver_id)
        if appointment.update({ status: :unassigned }) && appointment.unset(:driver_id)
          flash[:info] = 'Ride was unassigned.'
        else
          flash[:danger] = "Oops, that ride couldn't be unassigned."
        end
      else
        flash[:danger] = 'This appointment is already unassigned.'
      end
    end
    redirect_to root_url
  end

  def waiting; end

  private

  def is_on_call
    cur_time = Time.now
    day_of_week = cur_time.strftime('%A')
    cur_time_int = cur_time.strftime('%H%M').to_i
    driver = current_user
    driver_today_sch = driver.schedule.where(current: true).first[day_of_week]
    driver_today_time_start = driver_today_sch[0..3].to_i
    driver_today_time_end = driver_today_sch[5..8].to_i
    return false if driver_today_time_start == driver_today_time_end
    return false if cur_time_int < driver_today_time_start || cur_time_int > driver_today_time_end

    true
 end

  # Use callbacks to share common setup or constraints between actions.
  def set_driver
    @driver = Driver.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def driver_params
    params.require(:driver).permit(
      :first_name,
      :middle_init,
      :last_name,
      :phone,
      :email,
      :password,
      :password_confirmation,
      :car_make,
      :car_model,
      :car_color,
      :car_license_plate
    )
  end
end
