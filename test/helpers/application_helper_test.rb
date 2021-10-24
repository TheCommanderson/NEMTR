# frozen_string_literal: true

require 'test_helper'
include ApplicationHelper

class ApplicationHelperTest < ActiveSupport::TestCase
  test 'logged in for logged out user' do
    assert_not logged_in?
  end
end
