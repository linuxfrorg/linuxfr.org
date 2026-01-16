require "test_helper"

class StaticControllerTest < ActionDispatch::IntegrationTest
  test "should get home page" do
    get static_url pages(:one)

    assert_response :success
  end

  test "should get equipe page" do
    pages(:equipe).body = File.read("db/pages/equipe.html")
    pages(:equipe).save!

    get static_url pages(:equipe)

    assert_response :success
  end

  test "should get sites amis" do
    pages(:amis).body = File.read("db/pages/sites-amis.html")
    pages(:amis).save!

    get static_url pages(:amis)

    assert_response :success
  end

  test "should get règles de modération" do
    pages(:moderation).body = File.read("db/pages/regles_de_moderation.html")
    pages(:moderation).save!

    get static_url pages(:moderation)

    assert_response :success
  end

  test "get changelog" do
    get changelog_url pages(:one)

    assert_response :success
  end
end
