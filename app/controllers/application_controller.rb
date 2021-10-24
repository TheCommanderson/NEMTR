# frozen_string_literal: true

class ApplicationController < ActionController::Base
  require 'date'
  require 'time'
  include ApplicationHelper

  rescue_from ::StandardError, with: :handle_standard_error

  before_action :authorized

  add_flash_types :danger, :info

  # ===================== RESCUE =================== #
  def handle_standard_error(e)
    logger.error("encountered error: #{e}")
  end
end
