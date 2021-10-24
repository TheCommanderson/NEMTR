# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { 'Cara' }
    last_name { 'Spencer' }
    email { 'caraspencer@email.com' }
    password { 'password' }
  end
end
