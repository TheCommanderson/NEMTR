# frozen_string_literal: true

require 'test_helper'

class DriverTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test 'new driver created' do
    driver = build :driver
    assert_not_nil driver
  end

  test 'new driver has schedule' do
    driver = build :driver
    first_schedule = { Monday: '0000 0000',
                       Tuesday: '0000 0000',
                       Wednesday: '0000 0000',
                       Thursday: '0000 0000',
                       Friday: '0000 0000',
                       Saturday: '0000 0000',
                       Sunday: '0000 0000',
                       current: true }
    second_schedule = { Monday: '0000 0000',
                        Tuesday: '0000 0000',
                        Wednesday: '0000 0000',
                        Thursday: '0000 0000',
                        Friday: '0000 0000',
                        Saturday: '0000 0000',
                        Sunday: '0000 0000',
                        current: false }

    assert_not_nil driver.schedules
    assert_same driver.schedules.first, first_schedule
    assert_same driver.schedules.last, second_schedule
  end
end
