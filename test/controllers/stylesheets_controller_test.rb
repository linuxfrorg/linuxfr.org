require 'test_helper'

class StylesheetsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts 'visitor_0'
  end

  test 'should create stylesheet' do
    post stylesheet_url, params: {
      uploaded_stylesheet: fixture_file_upload('blue-smooth.scss', 'text/css')
    }

    assert flash[:notice]

    assert_redirected_to edit_stylesheet_url
  end

  test 'should not create stylesheet' do
    # Pour rendre l'utilisateur invalide et bloquer son enregistrement
    accounts('visitor_666').email = ''
    sign_in accounts 'visitor_666'

    post stylesheet_url, params: {
      uploaded_stylesheet: fixture_file_upload('blue-smooth.scss')
    }

    assert flash[:alert]

    assert_redirected_to edit_stylesheet_url
  end

  test 'should get edit' do
    get edit_stylesheet_url

    assert_response :success
  end

  test 'should not update stylesheet' do
    # Pour rendre l'utilisateur invalide et bloquer son enregistrement
    accounts('visitor_666').email = ''
    sign_in accounts 'visitor_666'

    patch stylesheet_url, params: {
      uploaded_stylesheet: fixture_file_upload('blue-smooth.scss')
    }

    assert flash[:alert]
    assert_redirected_to edit_stylesheet_url
  end

  test 'should update stylesheet to default' do
    patch stylesheet_url, params: {
      css_session: 'current'
    }

    assert flash[:notice]
    assert_redirected_to edit_stylesheet_url
  end

  test 'should update stylesheet' do
    patch stylesheet_url, params: {
      stylesheet: 'contrib/blue-smooth'
    }

    assert flash[:notice]
    assert_redirected_to edit_stylesheet_url
  end

  test 'should destroy stylesheet' do
    delete stylesheet_url

    assert flash[:notice]
    assert_redirected_to edit_stylesheet_url
  end
end
