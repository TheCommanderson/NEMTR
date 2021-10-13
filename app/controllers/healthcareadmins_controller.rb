# frozen_string_literal: true

class HealthcareadminsController < UsersController
  skip_before_action :authorized, only: %i[create new]
  before_action :set_healthcareadmin, only: %i[show edit update destroy approve]

  # GET /healthcareadmins or /healthcareadmins.json
  def index
    @patients = Patient.where(host_org: current_user.host_org).sort_by { |p| p.approved ? 0 : 1 }.sort_by(&:first_name)
  end

  # GET /healthcareadmins/1 or /healthcareadmins/1.json
  def show; end

  # GET /healthcareadmins/new
  def new
    @healthcareadmin = Healthcareadmin.new
  end

  # GET /healthcareadmins/1/edit
  def edit; end

  # POST /healthcareadmins or /healthcareadmins.json
  def create
    @healthcareadmin = Healthcareadmin.new(healthcareadmin_params)

    respond_to do |format|
      begin
        if @healthcareadmin.save
          format.html { redirect_to @healthcareadmin }
          format.json { render :show, status: :created, location: @healthcareadmin }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @healthcareadmin.errors, status: :unprocessable_entity }
        end
      rescue ArgumentError
        flash.now[:danger] = 'Please ensure all fields are filled in.'
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /healthcareadmins/1 or /healthcareadmins/1.json
  def update
    respond_to do |format|
      if @healthcareadmin.update(healthcareadmin_params)
        format.html { redirect_to @healthcareadmin, notice: 'healthcareadmin was successfully updated.' }
        format.json { render :show, status: :ok, location: @healthcareadmin }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @healthcareadmin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /healthcareadmins/1 or /healthcareadmins/1.json
  def destroy
    @healthcareadmin.destroy
    respond_to do |format|
      flash[:danger] = 'Healthcare administrator was successfully deleted.'
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_healthcareadmin
    @healthcareadmin = Healthcareadmin.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def healthcareadmin_params
    params.require(:healthcareadmin).permit(
      :first_name, :middle_init, :last_name, :phone, :email, :password, :host_org
    )
  end
end
