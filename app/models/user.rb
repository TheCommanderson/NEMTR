# frozen_string_literal: true

class User
  include Mongoid::Document
  include ActiveModel::SecurePassword

  field :first_name, type: String
  field :middle_init, type: String
  field :last_name, type: String
  field :phone, type: String
  field :email, type: String
  field :password_digest, type: String

  # validates :first_name, :last_name, :phone, :email, :password, presence: true
  validates_uniqueness_of :email, :phone
  # validates_length_of :phone, is: 10

  has_secure_password

  def full_name
    "#{first_name} #{middle_init} #{last_name}"
  end
end
