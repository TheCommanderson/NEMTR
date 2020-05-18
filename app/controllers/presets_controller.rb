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
    @patient.save
    redirect_to patient_presets_path
  end

  def edit
  end

  private
    def preset_params
      params.require(:preset).permit(:addr1, :addr2, :city, :state, :zip, :name)
    end
end
