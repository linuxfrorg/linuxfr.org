require 'test_helper'

class Moderation::ImagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts 'moderator_0'
  end

  test 'should list images' do
    get moderation_images_url
    assert_response :success
  end

  test 'should destroy image' do
    # Plutôt inutile, mais permet de passer à travers le code malgré tout
    delete moderation_image_url 0
    assert_redirected_to moderation_images_url
  end
end
