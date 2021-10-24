# frozen_string_literal: true

class SysadminsController < UsersController
  skip_before_action :authorized, only: %i[create new]
  before_action :set_sysadmin, only: %i[show edit update destroy host unhost]

  # GET /sysadmins or /sysadmins.json
  def index
    @patients = Patient.all.sort_by { |p| [p.approved.to_s, p.first_name] }
    @drivers = Driver.all.sort_by { |d| [d.trained.to_s, d.first_name] }
    @appointments = Appointment.all.sort_by { |a| [a.status, a.datetime] }
    @volunteers = Volunteer.all.sort_by { |v| [v.approved.to_s, v.first_name] }
    @sysadmin = Sysadmin.find(current_user.id)
  end

  # GET /sysadmins/1 or /sysadmins/1.json
  def show; end

  # GET /sysadmins/new
  def new
    @sysadmin = Sysadmin.new
  end

  # GET /sysadmins/1/edit
  def edit; end

  # POST /sysadmins or /sysadmins.json
  def create
    @sysadmin = Sysadmin.new(sysadmin_params)
    respond_to do |format|
      begin
        if @sysadmin.save
          format.html { redirect_to @sysadmin, notice: 'sysadmin was successfully created.' }
          format.json { render :show, status: :created, location: @sysadmin }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @sysadmin.errors, status: :unprocessable_entity }
        end
      rescue ArgumentError
        flash.now[:danger] = 'Please ensure all fields are filled in.'
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sysadmins/1 or /sysadmins/1.json
  def update
    respond_to do |format|
      if @sysadmin.update(sysadmin_params)
        flash[:info] = 'Info was successfully updated!'
        format.html { redirect_to @sysadmin }
        format.json { render :show, status: :ok, location: @sysadmin }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @sysadmin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sysadmins/1 or /sysadmins/1.json
  def destroy
    @sysadmin.destroy
    respond_to do |format|
      format.html { redirect_to root_url, notice: 'sysadmin was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def host
    @sysadmin.add_to_set(host_orgs: params[:host_org])
    @sysadmin.save
    flash[:info] = 'Successfully Added a new healthcare organization.'
    redirect_to sysadmins_path
  end

  def unhost
    if @sysadmin.host_orgs.include? params[:host]
      @sysadmin.host_orgs.delete(params[:host])
      @sysadmin.save
      flash[:info] = 'Healthcare organization was successfully removed.'
    else
      flash[:danger] = 'There was an error finding this healthcare organization, please try again.'
    end
    redirect_to sysadmins_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_sysadmin
    @sysadmin = Sysadmin.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def sysadmin_params
    params.require(:sysadmin).permit(
      :first_name, :middle_init, :last_name, :phone, :email, :password, :password_confirmation
    )
  end
end
