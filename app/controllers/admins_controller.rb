class AdminsController < ApplicationController
  before_action :set_admin, only: [:show, :edit, :update, :destroy]
  skip_before_action :authorized, only: [:new, :create]
  before_action :admin_authorized, except: [:new, :create]
   
  def train
   @driver = Driver.find(params[:id])
   @driver.update(trained: true)
   @driver.save
   redirect_to admins_home_path
  end
  
  def approve_patient
   @patient = Patient.find(params[:id])
   @patient.update(approved: true)
   @patient.save
   redirect_to admins_home_path
  end
  
  def approve
   @admin = Admin.find(params[:id])
   @admin.update(approved: true)
   @admin.save
   redirect_to admins_home_path
  end
  
  def unapprove
   @admin = Admin.find(params[:id])
   @admin.update(approved: false)
   @admin.save
   redirect_to admins_home_path
  end
  
  # GET /admins
  # GET /admins.json
  def index
    @currentAdmin = Admin.find(session[:user_id])
    @admins = Admin.all
    @patients = Patient.all
    @drivers = Driver.all
    @appointments = Appointment.all
    
    if request.post?
      params[:approvals].each do |id|
        #@admin = Admin.find(params[:id])
        #@admin.approved = true
      end
    end
    
  end

  # GET /admins/1
  # GET /admins/1.json
  def show
  end

  # GET /admins/new
  def new
    @admin = Admin.new
  end

  # GET /admins/1/edit
  def edit
  end

  # POST /admins
  # POST /admins.json
  def create
    @admin = Admin.new(admin_params)

    respond_to do |format|
      if @admin.save
        format.html { redirect_to @admin, notice: 'Admin was successfully created.' }
        format.json { render :show, status: :created, location: @admin }
      else
        format.html { render :new }
        format.json { render json: @admin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admins/1
  # PATCH/PUT /admins/1.json
  def update
    respond_to do |format|
      if @admin.update(admin_params)
        format.html { redirect_to @admin, notice: 'Admin was successfully updated.' }
        format.json { render :show, status: :ok, location: @admin }
      else
        format.html { render :edit }
        format.json { render json: @admin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admins/1
  # DELETE /admins/1.json
  def destroy
    @admin.destroy
    respond_to do |format|
      format.html { redirect_to admins_url, notice: 'Admin was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin
      @admin = Admin.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def admin_params
      params.require(:admin).permit(:first_name, :middle_init, :last_name, :phone, :email, :auth_lvl, :host_org, :password)
    end
    
    def admin_authorized
      redirect_to root_url unless session[:login_type] == 'A'
    end
end
