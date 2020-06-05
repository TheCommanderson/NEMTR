# frozen_string_literal: true

Rails.application.config.after_initialize do
  TEXTMAGIC_CLIENT = Textmagic::REST::Client.new 'spenceranderson1', Rails.application.credentials.textmagic_api_key
end
