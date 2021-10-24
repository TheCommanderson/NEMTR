# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActionController::TestCase
  include ApplicationHelper
  include FactoryBot::Syntax::Methods

  def setup
    @controller = SessionsController.new
    sign_out
  end

  test 'signing in and out' do
    user = if User.where(first_name: 'Cara').first.nil?
             create :user
           else
             User.where(first_name: 'Cara').first
           end

    sign_in user, 'password'
    assert logged_in?

    sign_out
    assert_not logged_in?
  end

  test 'sign' do
    assert_equal sign(1), '+'
    assert_equal sign(0), '+'
    assert_equal sign(-1), '-'
  end

  test 'dt format' do
    date = DateTime.new(2021, 10, 25, 0, 0, 0)
    assert_equal date.strftime(dt_format), '2021-10-25 00:00'
  end

  test 'get monday' do
    monday = Date.parse('25/10/2021')
    week = [monday].concat((1..6).map { |x| monday + x.days }.compact)
    expected = DateTime.new(2021, 10, 25, 5, 0, 0)

    week.each do |day|
      assert_equal get_monday(day), expected
    end
  end

  private

  def sign_in(user, password)
    post :create, params: { email: user.email, password: password }
  end

  def sign_out
    delete :logout
  end
end
