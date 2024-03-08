require "#{File.dirname(__FILE__)}/../test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should consult user" do
    get user_url(users(:community))

    assert_response :success
  end

  test "should consult news" do
    get news_user_url(users(:community))

    assert_response :success
  end

  test "should consult journaux" do
    get journaux_user_url(users(:community))

    assert_response :success
  end

  test "should consult liens" do
    get liens_user_url(users(:community))

    assert_response :success
  end

  test "should consult posts" do
    get posts_user_url(users(:community))

    assert_response :success
  end

  test "should consult suivi" do
    get suivi_user_url(users(:community))

    assert_response :success
  end

  test "should consult wiki" do
    get wiki_user_url(users(:community))

    assert_response :success
  end

  test "should consult comments" do
    get comments_user_url(users(:community))

    assert_response :success
  end
end
