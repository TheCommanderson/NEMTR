# frozen_string_literal: true

class Volunteer < User
  include Mongoid::Document
  include ActiveModel::SecurePassword

  # Volunteers must be approved to login
  field :approved, type: Boolean, default: false

  validates_presence_of :approved

  # Belongs
  belongs_to :sysadmin, optional: true
end
