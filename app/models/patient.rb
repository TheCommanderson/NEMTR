# frozen_string_literal: true

class Patient < User
  include Mongoid::Document

  field :approved, type: Boolean, default: false
  field :host_org, type: String

  validates_presence_of :approved

  # Embeds
  # Each patient can save preset locations that they often use for future
  # reference
  embeds_many :locations, cascade_callbacks: true
  accepts_nested_attributes_for :locations, allow_destroy: true

  # Belongs
  belongs_to :healthcareadmin, optional: true

  # Has
  has_many :appointments
  has_many :comments
end
