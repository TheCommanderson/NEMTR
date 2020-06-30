# frozen_string_literal: true

class Driver
  include Mongoid::Document
  include ActiveModel::SecurePassword

  field :first_name, type: String
  field :middle_init, type: String
  field :last_name, type: String
  field :phone, type: Integer
  field :email, type: String
  field :trained, type: Mongoid::Boolean
  field :admin_id, type: String
  field :blacklist, type: Array, default: []
  field :password_digest, type: String
  field :car_make, type: String
  field :car_model, type: String
  field :car_license_plate, type: String

  embeds_many :schedule
  accepts_nested_attributes_for :schedule

  validates_presence_of :first_name, :last_name, :phone, :email
  validates_uniqueness_of :email
  validates_length_of :phone, is: 10

  has_secure_password
  belongs_to :admin, optional: true
  has_many :appointments

  def self.blacklist_reset
    Driver.each do |driver|
      to_del = []
      driver.blacklist.each do |bl|
        appt = begin
                 Appointment.find(bl)
               rescue StandardError
                 nil
               end
        if appt.nil?
          to_del.append(bl)
        elsif Time.parse(appt.datetime).past?
          to_del.append(bl)
        end
      end
      to_del.each do |d|
        driver.blacklist.delete(d)
      end
      driver.save
    end
  end
end
