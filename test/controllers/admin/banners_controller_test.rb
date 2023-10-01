require 'test_helper'

class Admin::BannersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts 'admin_0'
  end

  test 'should list banners' do
    get admin_banners_url
    assert_response :success
  end

  test 'should get new' do
    get new_admin_banner_url
    assert_response :success
  end

  test 'should preview banner' do
    assert_no_difference('Banner.count') do
      post admin_banners_url,
           params: {
             banner: {
               title: 'Hello world',
               content: 'This is a banner'
             },
             commit: 'Prévisualiser'
           }
    end
    assert_response :success
  end

  test 'should create banner' do
    assert_difference('Banner.count') do
      post admin_banners_url,
           params: {
             banner: {
               title: 'Hello world',
               content: 'This is a banner'
             }
           }
    end
    assert_redirected_to admin_banners_url
  end

  test 'should edit banner' do
    get edit_admin_banner_url(banners(:one))
    assert_response :success
  end

  test 'should preview update banner' do
    assert_no_difference('Banner.count') do
      patch admin_banner_url(banners(:one)),
            params: {
              banner: {
                title: 'Hello world',
                content: 'This is a banner'
              },
              commit: 'Prévisualiser'
            }
    end
    assert_response :success
  end

  test 'should update banner' do
    patch admin_banner_url(banners(:one)),
          params: {
            banner: {
              title: 'Hello world',
              content: 'This is a banner'
            }
          }
    assert_redirected_to admin_banners_url
  end

  test 'should destroy banner' do
    assert_difference('Banner.count', -1) do
      delete admin_banner_url(banners(:one))
    end
    assert_redirected_to admin_banners_url
  end
end
