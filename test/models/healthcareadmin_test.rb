# frozen_string_literal: true

require 'test_helper'

class HealthcareadminTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test 'new healthcareadmin created' do
    hca = build :hca
    assert_not_nil hca
  end
end
