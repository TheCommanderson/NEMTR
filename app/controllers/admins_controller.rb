# frozen_string_literal: true

require 'securerandom'
require 'date'

class AdminsController < ApplicationController
  before_action :set_admin, only: %i[show edit update destroy index add_host delete_host approve]
  skip_before_action :authorized, only: %i[new create]
  before_action :admin_authorized, except: %i[new create]

  # 1 = Sys admin, 2 = healthcare provider, 3 = call center
  AUTH_LEVELS = ['System Administrator', 'Healthcare Provider', 'Call Center'].freeze

  def add_host
    if @current_admin.auth_lvl > 1
      flash[:notice] = 'Only system administrators may create new host organizations!'
    else
      @current_admin.add_to_set(host_orgs: params[:host_org])
      @current_admin.save
      flash[:notice] = "Host organization #{params[:host_org]} has been added."
    end
    redirect_to admins_home_path
  end

  def delete_host
    if @current_admin.host_orgs.include? params[:id]
      @current_admin.delete(params[:id])
      @current_admin.save
      flash[:notice] = "Host organization #{params[:id]} removed."
    else
      flash[:notice] = "You are not the admin who added the host organization #{params[:id]}, so it could not be removed."
    end
    redirect_to admins_home_path
  end

  def approve
    case user_type(params[:id])
    when 'A'
      @admin = Admin.find(params[:id])
      @admin.update(approved: true)
      @admin.update(admin_name: @current_admin.first_name + ' ' + @current_admin.last_name)
      @admin.update(admin_email: @current_admin.email)
      @admin.save
    when 'P'
      @patient = Patient.find(params[:id])
      @patient.update(approved: true)
      @patient.update(admin: @current_admin)
      @patient.save
    when 'D'
      @driver = Driver.find(params[:id])
      @driver.update(trained: true)
      @driver.update(admin: @current_admin)
      @driver.save
    else
      flash[:notice] = "An internal error occurred while fetching this user, could not approve.  ID: #{params[:id]}"
    end
    redirect_to admins_home_path
  end

  def unapprove
    case user_type(params[:id])
    when 'A'
      @admin = Admin.find(params[:id])
      @admin.update(approved: false)
      @admin.remove_attribute(:admin_name)
      @admin.remove_attribute(:admin_email)
      @admin.save
    when 'P'
      @patient = Patient.find(params[:id])
      @patient.update(approved: false)
      @patient.update(admin: Admin.find(session[:user_id]))
      @patient.save
    when 'D'
      @driver = Driver.find(params[:id])
      @driver.update(trained: false)
      @driver.update(admin: Admin.find(session[:user_id]))
      @driver.save
    else
      flash[:notice] = "An internal error occurred while fetching this user, could not unapprove.  ID: #{params[:id]}"
     end
    redirect_to admins_home_path
  end

  def reset
    # TODO(spencer) remove type param from reset call in admin index.html
    case user_type(params[:id])
    when 'P'
      @user = Patient.find(params[:id])
    when 'D'
      @user = Driver.find(params[:id])
    when 'A'
      @user = Admin.find(params[:id])
    else
      flash[:notice] = "An internal error occurred while fetching user, could not reset password.  ID: #{params[:id]}"
      return
    end

    temp_password = SecureRandom.base64(15)
    @user.update(password: temp_password)
    @user.save
    flash[:notice] = "Successfully reset #{@user.first_name} #{@user.last_name}'s password to #{temp_password}"
    redirect_to admins_home_path
  end

  # GET /admins
  # GET /admins.json
  def index
    # TODO(spencer) change currentAdmin to current_admin in admins.index and remove this line
    @currentAdmin = @current_admin
    @dt_format = dt_format
    @admins = admin_search.sort_by { |adm| [adm.approved.to_s, adm.auth_lvl, adm.first_name] }
    @patients = patient_search.sort_by { |patient| [patient.approved.to_s, patient.first_name] }
    @drivers = driver_search.sort_by { |drvr| [drvr.trained.to_s, drvr.first_name] }
    @appointments = Appointment.all.sort_by { |appt| [appt.status, appt.datetime] }
  end

  def admin_search
    @admins = if params[:admin_search]
                search(Admin.all, params[:admin_search])
              else
                Admin.all
              end
  end

  def driver_search
    @drivers = if params[:driver_search]
                 search(Driver.all, params[:driver_search])
               else
                 Driver.all
               end
  end

  def patient_search
    @patients = if @currentAdmin.auth_lvl == 2
                  Patient.all.where({ host_org: @currentAdmin.host_org })
                else
                  Patient.all
                end

    @patients = if params[:patient_search]
                  search(@patients, params[:patient_search])
                else
                  @patients
                end
  end

  def search(obj, param)
    if param
      @parameter = /#{param}/i
      @full_name = param.gsub(/\s+/m, ' ').strip.split(' ')
      if @full_name.length > 1
        @first = /#{@full_name[0]}/i
        @second = /#{@full_name[1]}/i
      end

      @result = if @full_name.length > 1
                  obj.where('$and' => [{ first_name: @first }, { last_name: @second }])
                else
                  obj.where('$or' => [{ first_name: @parameter }, { last_name: @parameter }, { email: @parameter }])
                end
    else
      @result = obj
    end
    @result
  end

  # GET /admins/1
  # GET /admins/1.json
  def show; end

  # GET /admins/new
  def new
    @current_admin = Admin.new
  end

  # GET /admins/1/edit
  def edit; end

  # POST /admins
  # POST /admins.json
  def create
    @current_admin = Admin.new(admin_params)
    @current_admin.approved = false unless @current_admin.approved

    respond_to do |format|
      if @current_admin.save
        AdminMailer.with(admin: @current_admin).new_admin_email.deliver
        format.html { redirect_to @current_admin, notice: 'Admin was successfully created.' }
        format.json { render :show, status: :created, location: @current_admin }
      else
        format.html { render :new }
        format.json { render json: @current_admin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admins/1
  # PATCH/PUT /admins/1.json
  def update
    respond_to do |format|
      if @current_admin.update(admin_params)
        format.html { redirect_to @current_admin, notice: 'Update was successful!' }
        format.json { render :show, status: :ok, location: @current_admin }
      else
        format.html { render :edit }
        format.json { render json: @current_admin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admins/1
  # DELETE /admins/1.json
  def destroy
    @current_admin.destroy
    respond_to do |format|
      format.html { redirect_to admins_url, notice: 'Admin was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_admin
    @current_admin = current_user
  end

  # Only allow a list of trusted parameters through.
  def admin_params
    params.require(:admin).permit(:first_name, :middle_init, :last_name, :admin_name, :admin_email, :phone, :email, :auth_lvl, :host_org, :password)
  end

  def admin_authorized
    redirect_to root_url unless session[:login_type] == 'A'
  end
end
