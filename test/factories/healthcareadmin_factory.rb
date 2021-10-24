# frozen_string_literal: true

FactoryBot.define do
  factory :hca, class: 'Healthcareadmin' do
    first_name { 'Roger' }
    middle_init { 'D' }
    last_name { 'Park' }
    phone { '(987) 654 3210' }
    email { 'rdp@hotmail.com' }
    password { 'rogeristhebest' }
    host_org { 'XYZ Healthcare' }
    approved { true }
  end
end
