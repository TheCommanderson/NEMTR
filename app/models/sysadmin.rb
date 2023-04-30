# frozen_string_literal: true

class Sysadmin < User
  include Mongoid::Document

  # System admins will have a list of host orgs that they have approved to be
  # part of the program.
  field :host_orgs, type: Array, default: []
  field :approved, type: Boolean, default: false

  # Has
  has_many :drivers
  has_many :healthcareadmins
  has_many :volunteers
end
