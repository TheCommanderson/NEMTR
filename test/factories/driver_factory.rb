# frozen_string_literal: true

FactoryBot.define do
  factory :driver do
    first_name { 'Gerald' }
    middle_init { 'M' }
    last_name { 'Hashburrow' }
    phone { '(123) 456 7890' }
    email { 'gerald.hashburrow@yahoo.com' }
    password { 'geraldrulez' }
    car_make { 'Toyota' }
    car_model { 'Corolla' }
    car_color { 'Green' }
    car_license_plate { 'ABC123' }
  end
end
