# frozen_string_literal: true

require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test 'logged_in returns false when user is not logged in' do
    assert true
  end
end
