# frozen_string_literal: true

class SchedulesController < ApplicationController
  skip_before_action :authorized, only: %i[create new]
  before_action :set_schedule, only: %i[show edit destroy]

  # GET /schedules or /schedules.json
  def index
    @driver = Driver.find(params[:driver_id])
    @current_schedule = @driver.schedules.where(current: true).first
    @next_schedule = @driver.schedules.where(current: false).first
    @this_monday = get_monday(DateTime.now)
    @next_monday = get_monday(Time.current + 7.days).to_datetime
    @schedules = [
      { id: @current_schedule.id, sch: pretty_print_schedule(@current_schedule), days: getDatesOfWeek(@this_monday) },
      { id: @next_schedule.id, sch: pretty_print_schedule(@next_schedule), days: getDatesOfWeek(@next_monday) }
    ]
  end

  # GET /schedules/1 or /schedules/1.json
  def show; end

  # GET /schedules/new
  def new; end

  # GET /schedules/1/edit
  def edit
    @days = if @schedule.current
              getDatesOfWeek(get_monday(DateTime.now))
            else
              getDatesOfWeek(get_monday(Time.current + 7.days).to_datetime)
            end
  end

  # POST /schedules or /schedules.json
  def create
    @schedule = Schedule.new(schedule_params)
    respond_to do |format|
      if @schedule.save
        format.html { redirect_to @schedule, notice: 'schedule was successfully created.' }
        format.json { render :show, status: :created, location: @schedule }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /schedules/1 or /schedules/1.json
  def update
    params[:driver_id] = params[:d_id]
    @schedule = Driver.find(params[:driver_id]).schedules.find(params[:id])
    flash[:notice] = ''
    new_sch = {}
    days = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
    days.each do |day|
      day1 = (params[:schedule][day + '1(4i)']).to_s + (params[:schedule][day + '1(5i)']).to_s
      day2 = (params[:schedule][day + '2(4i)']).to_s + (params[:schedule][day + '2(5i)']).to_s
      if day1.to_i > day2.to_i
        flash[:info] += day + ' was not updated, invalid time given.  '
        next
      end
      new_sch[day] = day1 + ' ' + day2
    end

    respond_to do |format|
      if @schedule.update(new_sch)
        if flash[:info]
          flash[:info] += 'Schedule updated.'
        else
          flash[:info] = 'Schedule updated.'
        end
        MatchingEngine.matching_alg
        format.html { redirect_to driver_schedules_path(current_user) }
        format.json { render :show, status: :ok, location: @schedule }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /schedules/1 or /schedules/1.json
  def destroy
    @schedule.destroy
    respond_to do |format|
      format.html { redirect_to root_url, notice: 'schedule was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def pretty_print_schedule(schedule)
    @sch = {}
    schedule.attributes.each do |name, val|
      next unless daysOfTheWeek.include? name

      if val[0..3] == val[5..8]
        @sch[name] = 'None'
      else
        ampm1 = 'AM'
        if val[0..1].to_i > 12
          h1 = val[0..1].to_i % 12
          ampm1 = 'PM'
        else
          h1 = val[0..1].to_i
        end
        ampm2 = 'AM'
        if val[5..6].to_i > 12
          h2 = val[5..6].to_i % 12
          ampm2 = 'PM'
        else
          h2 = val[5..6].to_i
        end
        day_str = h1.to_s + ':' + val[2..3] + ampm1 + ' to ' + h2.to_s + ':' + val[7..8] + ampm2
        @sch[name] = day_str
      end
    end
    @sch
  end

  def getDatesOfWeek(monday)
    dates = {}
    (0..6).each { |i| dates[daysOfTheWeek[i]] = (monday.to_time + i.days).strftime('%B %-d') }
    dates
  end

  def daysOfTheWeek
    %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_schedule
    @schedule = Driver.find(params[:driver_id]).schedules.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def schedule_params
    params.require(:schedule).permit(
      :first_name, :middle_init, :last_name, :phone, :email, :password
    )
  end
end
