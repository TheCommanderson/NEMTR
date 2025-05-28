# frozen_string_literal: true

class VolunteersController < UsersController
  skip_before_action :authorized, only: %i[create new]
  before_action :set_volunteer, only: %i[show edit update destroy approve]

  # GET /volunteers or /volunteers.json
  def index
    @patients = Patient.all.sort_by { |p| [p.approved.to_s, p.first_name] }
    @drivers = Driver.all.sort_by { |d| [d.trained.to_s, d.first_name] }
    @appointments = Appointment.all.sort_by { |a| [a.status, Time.parse(a.datetime)] }
  end

  # GET /volunteers/1 or /volunteers/1.json
  def show; end

  # GET /volunteers/new
  def new
    @volunteer = Volunteer.new
  end

  # GET /volunteers/1/edit
  def edit; end

  # POST /volunteers or /volunteers.json
  def create
    @volunteer = Volunteer.new(volunteer_params)
    respond_to do |format|
      begin
        if @volunteer.save
          AdminMailer.with(volunteer: @volunteer).new_volunteer_email.deliver
          format.html { redirect_to @volunteer, notice: 'volunteer was successfully created.' }
          format.json { render :show, status: :created, location: @volunteer }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @volunteer.errors, status: :unprocessable_entity }
        end
      rescue ArgumentError
        flash.now[:danger] = 'Please ensure all fields are filled in.'
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /volunteers/1 or /volunteers/1.json
  def update
    respond_to do |format|
      if @volunteer.update(volunteer_params)
        flash[:info] = 'Info was successfully updated!'
        format.html { redirect_to @volunteer }
        format.json { render :show, status: :ok, location: @volunteer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @volunteer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /volunteers/1 or /volunteers/1.json
  def destroy
    @volunteer.destroy
    respond_to do |format|
      format.html { redirect_to root_url, notice: 'volunteer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def approve
    @volunteer.update_attribute(:approved, !@volunteer.approved)
    if @volunteer.approved && @volunteer.update_attribute(:sysadmin, current_user)
      flash[:info] = 'Approved!'
    elsif !@volunteer.approved && @volunteer.unset(:sysadmin)
      flash[:info] = 'Volunteer unapproved successfully.'
    else
      flash[:danger] = 'There was an error (un)approving this volunteer, please try again.'
    end
    redirect_to root_url
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_volunteer
    @volunteer = Volunteer.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def volunteer_params
    params.require(:volunteer).permit(
      :first_name, :middle_init, :last_name, :phone, :email, :password, :password_confirmation
    )
  end
end
