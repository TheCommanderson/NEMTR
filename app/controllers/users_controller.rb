# frozen_string_literal: true

require 'securerandom'

class UsersController < ApplicationController
  skip_before_action :authorized, only: %i[create new]
  before_action :set_user, only: %i[show edit update destroy password reset]

  # GET /users or /users.json
  def index
    @users = User.all
  end

  # GET /users/1 or /users/1.json
  def show; end

  # GET /users/new
  def new; end

  # GET /users/1/edit
  def edit; end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'user was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        flash[:info] = 'Info was successfully updated!'
        format.html { redirect_to @user }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to root_url, notice: 'user was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def password; end

  def reset
    password = SecureRandom.base64(15)
    @user.update(password: password)
    if @user.save
      AdminMailer.with(password: password, user_email: @user.email).password_reset_email.deliver
      flash[:info] = "#{@user.first_name}'s new password is '#{password}'"
    else
      flash[:danger] = "#{@user.first_name}'s password could not be reset!"
    end
    redirect_to root_url
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(
      :first_name, :middle_init, :last_name, :phone, :email, :password
    )
  end
end
