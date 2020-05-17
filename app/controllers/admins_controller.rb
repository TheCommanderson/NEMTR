class AdminsController < ApplicationController
  before_action :set_admin, only: [:show, :edit, :update, :destroy]
  skip_before_action :authorized, only: [:new, :create]
  before_action :admin_authorized, except: [:new, :create]
  
  HOSTS = ['N/A','A&M','United Way']
  AUTH_LEVELS = ['System Administrator','Healthcare Provider','Call Center']
  
  def add_host
    HOSTS.push(params[:host_org])
    HOSTS.sort!
    redirect_to admins_home_path
  end
  
  def delete_host
    HOSTS.delete(params[:id])
    redirect_to admins_home_path
  end
  
  def approve
    if !Admin.where(:id => params[:id]).blank?
      @admin = Admin.find(params[:id])
      @admin.update(approved: true)
      @tmp = Admin.find(session[:user_id])
      @admin.update(admin_name: @tmp.first_name + " " + @tmp.last_name)
      @admin.update(admin_email: @tmp.email)
      @admin.save
    elsif !Patient.where(:id => params[:id]).blank?
      @patient = Patient.find(params[:id])
      @patient.update(approved: true)
      @patient.update(admin: Admin.find(session[:user_id]))
      @patient.save
    elsif !Driver.where(:id => params[:id]).blank?
      @driver = Driver.find(params[:id])
      @driver.update(trained: true)
      @driver.update(admin: Admin.find(session[:user_id]))
      @driver.save
    end
   redirect_to admins_home_path
  end
  
  def unapprove
   if !Admin.where(:id => params[:id]).blank?
      @admin = Admin.find(params[:id])
      @admin.update(approved: false)
      @tmp = Admin.find(session[:user_id])
      @admin.update(admin_name: @tmp.first_name + " " + @tmp.last_name)
      @admin.update(admin_email: @tmp.email)
      @admin.save
    elsif !Patient.where(:id => params[:id]).blank?
      @patient = Patient.find(params[:id])
      @patient.update(approved: false)
      @patient.update(admin: Admin.find(session[:user_id]))
      @patient.save
    elsif !Driver.where(:id => params[:id]).blank?
      @driver = Driver.find(params[:id])
      @driver.update(trained: false)
      @driver.update(admin: Admin.find(session[:user_id]))
      @driver.save
    end
   redirect_to admins_home_path
  end
  
  # GET /admins
  # GET /admins.json
  def index
    @currentAdmin = Admin.find(session[:user_id])
    @admins = self.admin_search.sort_by{ |adm| [ adm.approved.to_s, adm.auth_lvl, adm.first_name ] }
    @patients = self.patient_search.sort_by{ |patient| [patient.approved.to_s, patient.first_name] }
    @drivers = self.driver_search.sort_by{ |drvr| [ drvr.trained.to_s, drvr.first_name ] }
    @appointments = Appointment.all.sort_by{ |appt| [ appt.status, appt.datetime ] }
  end
  
  def admin_search
    if params[:a_search]
      @admins = self.search(Admin.all)
    else
      @admins = Admin.all
    end
  end
  
  def driver_search
    if params[:d_search]
      @drivers = self.search(Driver.all)
    else
      @drivers = Driver.all
    end
  end
  
  def patient_search
    if @currentAdmin.auth_lvl == 2 
      @patients = Patient.all.where({host_org: @currentAdmin.host_org})
    else
      @patients = Patient.all
    end
    
    if params[:p_search]
      @patients = self.search(@patients)
    else
      @patients = @patients
    end
  end
  
  def search(obj)
    if params[:search]
      @parameter = /#{params[:search]}/i
      @full_name = params[:search].gsub(/\s+/m, ' ').strip.split(" ")
      if @full_name.length > 1
        @first = /#{@full_name[0]}/i
        @second = /#{@full_name[1]}/i
      end
      
      if @full_name.length > 1
        @result = obj.where('$and' => [{first_name: @first},{last_name: @second}])
      else
        @result = obj.where('$or' => [{first_name: @parameter},{last_name: @parameter},{email: @parameter}])
      end
    else
      @result = obj
    end
    return @result
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
    if (!@admin.approved)
      @admin.approved = false
    end

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
      params.require(:admin).permit(:first_name, :middle_init, :last_name, :admin_name, :admin_email, :phone, :email, :auth_lvl, :host_org, :password)
    end
    
    def admin_authorized
      redirect_to root_url unless session[:login_type] == 'A'
    end
end
