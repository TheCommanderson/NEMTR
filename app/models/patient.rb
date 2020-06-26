# frozen_string_literal: true

class Patient
  include Mongoid::Document
  include ActiveModel::SecurePassword

  field :first_name, type: String
  field :middle_initial, type: String
  field :last_name, type: String
  field :phone, type: Integer
  field :email, type: String
  field :host_org, type: String
  field :admin_id, type: String
  field :approved, type: Boolean
  field :password_digest, type: String
  field :comments, type: Array, default: []

  validates_presence_of :first_name, :last_name, :phone, :email
  validates_uniqueness_of :email
  validates_length_of :phone, is: 10

  has_secure_password
  belongs_to :admin, optional: true
  has_many :appointments
  embeds_many :preset
  accepts_nested_attributes_for :preset
end
