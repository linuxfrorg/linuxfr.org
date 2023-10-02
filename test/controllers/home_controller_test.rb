require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'should get index' do
    # Permet d'indexer les bannières, nécessaire à la récupération plus tard
    banners(:one).save!

    get root_url
    assert_response :success

    assert_select 'title', 'Accueil - LinuxFr.org'

    post destroy_account_session_url
  end

  test 'should not login' do
    sign_in accounts :anonymous
    get trackers_url
    assert flash[:alert]
    assert_redirected_to account_session_url
  end
end
