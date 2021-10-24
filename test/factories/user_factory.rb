# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { 'Cara' }
    last_name { 'Spencer' }
    password { 'password' }
  end
end
