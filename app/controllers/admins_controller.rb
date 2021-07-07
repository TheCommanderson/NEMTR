# frozen_string_literal: true

require 'securerandom'
require 'date'

class AdminsController < ApplicationController
  before_action :set_admin, only: %i[show edit update destroy add_host delete_host approve index]
  skip_before_action :authorized, only: %i[new create]
  before_action :admin_authorized, except: %i[new create]

  # 1 = Sys admin, 2 = healthcare provider, 3 = call center
  AUTH_LEVELS = ['System Administrator', 'Healthcare Provider', 'Call Center'].freeze

  def add_host
    if @admin.auth_lvl > 1
      flash[:notice] = 'Only system administrators may create new host organizations!'
    else
      @admin.add_to_set(host_orgs: params[:host_org])
      @admin.save
      flash[:notice] = "Host organization #{params[:host_org]} has been added."
    end
    redirect_to admins_home_path
  end

  def delete_host
    if @admin.host_orgs.include? params[:id]
      @admin.host_orgs.delete(params[:id])
      @admin.save
      flash[:notice] = "Host organization #{params[:id]} removed."
    else
      flash[:notice] = "You are not the admin who added the host organization #{params[:id]}, so it could not be removed."
    end
    redirect_to admins_home_path
  end

  def approve
    case user_type(params[:id])
    when 'A'
      a = Admin.find(params[:id])
      a.update(approved: true)
      a.update(admin_name: @admin.first_name + ' ' + @admin.last_name)
      a.update(admin_email: @admin.email)
      a.save
    when 'P'
      p = Patient.find(params[:id])
      p.update(approved: true)
      p.update(admin: @admin)
      p.save
    when 'D'
      d = Driver.find(params[:id])
      d.update(trained: true)
      d.update(admin: @admin)
      d.save
    else
      flash[:notice] = "An internal error occurred while fetching this user, could not approve.  ID: #{params[:id]}"
    end
    redirect_to admins_home_path
  end

  def unapprove
    case user_type(params[:id])
    when 'A'
      a = Admin.find(params[:id])
      a.update(approved: false)
      a.remove_attribute(:admin_name)
      a.remove_attribute(:admin_email)
      a.save
    when 'P'
      p = Patient.find(params[:id])
      p.update(approved: false)
      p.remove_attribute(:admin)
      p.save
    when 'D'
      d = Driver.find(params[:id])
      d.update(trained: false)
      d.remove_attribute(:admin)
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
    AdminMailer.with(user_email: @user.email, password: temp_password).password_reset_email.deliver
    flash[:notice] = "Successfully reset #{@user.first_name} #{@user.last_name}'s password to #{temp_password}"
    redirect_to admins_home_path
  end

  # GET /admins
  # GET /admins.json
  def index
    @currentAdmin = @admin
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
        AdminMailer.with(admin: @admin).new_admin_email.deliver
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
    @admin = current_user
  end

  # Only allow a list of trusted parameters through.
  def admin_params
    params.require(:admin).permit(:first_name, :middle_init, :last_name, :admin_name, :admin_email, :phone, :email, :auth_lvl, :host_org, :password)
  end

  def admin_authorized
    redirect_to root_url unless session[:login_type] == 'A'
  end
end
