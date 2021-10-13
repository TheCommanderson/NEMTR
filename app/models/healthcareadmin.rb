# frozen_string_literal: true

class Healthcareadmin < User
  include Mongoid::Document

  # The healthcare org that this healthcare admin belongs to
  field :host_org, type: String
  # Volunteers must be approved to login
  field :approved, type: Boolean, default: false

  validates_presence_of :approved

  # Belongs
  belongs_to :sysadmin, optional: true

  # Has
  # Each healthcare admin is responsible for their own patients
  has_many :patients
end
