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

  has_secure_password

  def full_name
    "#{first_name} #{middle_init} #{last_name}"
  end

  def phone_number
    "#{phone[1..3]}#{phone[6..8]}#{phone[10..13]}"
  end

  def user_type
    if _type == 'Healthcareadmin'
      'Healthcare Admin'
    elsif _type == 'Sysadmin'
      'System Admin'
    elsif _type == 'Patient'
      'User'
    elsif _type == 'Volunteer'
      'Dispatcher'
    else
      _type
    end
  end
end
