require 'test_helper'

class DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts 'maintainer_0'
  end

  test 'should get index' do
    get dashboard_url
    assert_response :success
  end

  test 'should get answers' do
    get tableau_de_bord_reponses_url
    assert_response :success
  end
end
