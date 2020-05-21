class PresetsController < ApplicationController
  def index
    @patient = Patient.find(params[:patient_id])
  end

  def new
    @patient = Patient.find(params[:patient_id])
    @preset = @patient.preset.new
  end

  def create
    @patient = Patient.find(params[:patient_id])
    @preset = @patient.preset.build(preset_params)
    if @patient.save
      redirect_to patient_presets_path
    else
      flash[:notice] = "Required fields are missing data."
      redirect_back(fallback_location: root_url)
    end
  end

  def quickAdd
    @patient = Patient.find(params[:patient_id])
    tmp_patient = Patient.where(:'preset.id' => params[:preset_id]).first
    copy_from = tmp_patient.preset.find(params[:preset_id])
    @params = preset_params
    @params[:addr1] = copy_from[:addr1]
    @params[:addr2] = copy_from[:addr2]
    @params[:city] = copy_from[:city]
    @params[:state] = copy_from[:state]
    @params[:zip] = copy_from[:zip]
    @preset = @patient.preset.build(@params)
    @patient.save
    redirect_to patient_presets_path
  end

  def edit
  end

  def destroy
    @patient = Patient.find(params[:patient_id])
    @preset = @patient.preset.find(params[:id])
    @preset.destroy
    redirect_to patient_presets_path
  end

  private
    def preset_params
      params.require(:preset).permit(:addr1, :addr2, :city, :state, :zip, :name)
    end
end
