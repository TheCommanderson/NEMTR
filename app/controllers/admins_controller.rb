# frozen_string_literal: true

require 'securerandom'
require 'date'

class AdminsController < ApplicationController
  before_action :set_admin, only: %i[show edit update destroy]
  skip_before_action :authorized, only: %i[new create]
  before_action :admin_authorized, except: %i[new create]

  HOSTS = ['N/A', 'A&M', 'United Way'].freeze
  AUTH_LEVELS = ['System Administrator', 'Healthcare Provider', 'Call Center'].freeze

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
    if !Admin.where(id: params[:id]).blank?
      @admin = Admin.find(params[:id])
      @admin.update(approved: true)
      @tmp = Admin.find(session[:user_id])
      @admin.update(admin_name: @tmp.first_name + ' ' + @tmp.last_name)
      @admin.update(admin_email: @tmp.email)
      @admin.save
    elsif !Patient.where(id: params[:id]).blank?
      @patient = Patient.find(params[:id])
      @patient.update(approved: true)
      @patient.update(admin: Admin.find(session[:user_id]))
      @patient.save
    elsif !Driver.where(id: params[:id]).blank?
      @driver = Driver.find(params[:id])
      @driver.update(trained: true)
      @driver.update(admin: Admin.find(session[:user_id]))
      @driver.save
    end
    redirect_to admins_home_path
  end

  def unapprove
    if !Admin.where(id: params[:id]).blank?
      @admin = Admin.find(params[:id])
      @admin.update(approved: false)
      @tmp = Admin.find(session[:user_id])
      @admin.update(admin_name: @tmp.first_name + ' ' + @tmp.last_name)
      @admin.update(admin_email: @tmp.email)
      @admin.save
    elsif !Patient.where(id: params[:id]).blank?
      @patient = Patient.find(params[:id])
      @patient.update(approved: false)
      @patient.update(admin: Admin.find(session[:user_id]))
      @patient.save
    elsif !Driver.where(id: params[:id]).blank?
      @driver = Driver.find(params[:id])
      @driver.update(trained: false)
      @driver.update(admin: Admin.find(session[:user_id]))
      @driver.save
     end
    redirect_to admins_home_path
  end

  def reset
    temp_password = SecureRandom.base64(15)
    if params[:type] == 'patient'
      @user = Patient.find(params[:id])
    elsif params[:type] == 'driver'
      @user = Driver.find(params[:id])
    elsif params[:type] == 'admin'
      @user = Admin.find(params[:id])
    end

    @user.update(password: temp_password)
    @user.save

    flash[:notice] = "Successfully reset #{@user.first_name} #{@user.last_name}'s password to #{temp_password}"
    redirect_to admins_home_path
  end

  # GET /admins
  # GET /admins.json
  def index
    @currentAdmin = Admin.find(session[:user_id])
    @dt_format = dt_format
    @admins = admin_search.sort_by { |adm| [adm.approved.to_s, adm.auth_lvl, adm.first_name] }
    @patients = patient_search.sort_by { |patient| [patient.approved.to_s, patient.first_name] }
    @drivers = driver_search.sort_by { |drvr| [drvr.trained.to_s, drvr.first_name] }
    @appointments = Appointment.all.sort_by { |appt| [appt.status, appt.datetime] }
  end

  def admin_search
    @admins = if params[:admin_search]
                search(Admin.all,params[:admin_search])
              else
                Admin.all
              end
  end

  def driver_search
    @drivers = if params[:driver_search]
                 search(Driver.all,params[:driver_search])
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
                  search(@patients,params[:patient_search])
                else
                  @patients
                end
  end

  def search(obj,param)
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
    @admin = Admin.new
  end

  # GET /admins/1/edit
  def edit; end

  # POST /admins
  # POST /admins.json
  def create
    @admin = Admin.new(admin_params)
    @admin.approved = false unless @admin.approved

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
        format.html { redirect_to @admin, notice: 'Update was successful!' }
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
      format.html { redirect_to admins_url, notice: 'Admin was successfully deleted.' }
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
