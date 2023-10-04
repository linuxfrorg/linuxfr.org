require 'test_helper'

class DiariesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in accounts 'moderator_0'
  end

  test 'get index' do
    get diaries_url

    assert_response :success
  end

  test 'can not show' do
    get user_diary_url users('visitor_0'), diaries(:lorem_cc_licensed)

    assert_redirected_to user_diary_url users('visitor_2'), diaries(:lorem_cc_licensed)
  end

  test 'get show' do
    get user_diary_url(users('visitor_1'), diaries(:lorem_cc_licensed), format: :html)

    assert_response :success
  end

  test 'can not get new' do
    sign_in accounts 'visitor_zero_karma'
    get new_diary_url

    assert_response :forbidden
  end

  test 'get new' do
    get new_diary_url

    assert_response :success
  end

  test 'preview diary' do
    assert_no_difference 'Diary.count' do
      post diaries_url, params: {
        diary: { title: 'Hello world' },
        tags: 'foo, bar',
        commit: 'Prévisualiser'
      }
    end
    assert_response :success
  end

  test 'create diary' do
    assert_difference 'Diary.count' do
      post diaries_url, params: {
        diary: {
          title: 'Hello world',
          wiki_body: 'et le reste'
        }, tags: 'foo, bar'
      }

      assert flash[:notice]
    end
    assert_redirected_to user_diary_url(users('moderator_0'), Diary.last)
  end

  test 'get edit' do
    get edit_user_diary_url users('visitor_1').id, diaries(:lorem_cc_licensed).id

    assert_response :success
  end

  test 'preview update diary' do
    patch user_diary_url(users('visitor_1'), diaries(:lorem_cc_licensed)), params: {
      diary: { title: 'Nouveau titre' },
      commit: 'Prévisualiser'
    }

    assert_response :success
  end

  test 'update diary' do
    patch user_diary_url(users('visitor_1'), diaries(:lorem_cc_licensed)), params: {
      diary: { title: 'Nouveau titre' }
    }

    assert flash[:notice]
    assert_redirected_to user_diary_url(users('visitor_1'), 'nouveau-titre')
  end

  test 'destroy diary' do
    assert_difference 'Diary.all.find_all { |d| d.visible? }.count', -1 do
      delete user_diary_url(users('visitor_2'), diaries(:lorem_cc_licensed))

      assert flash[:notice]
    end
    assert_redirected_to diaries_url
  end

  test 'do not convert diary' do
    sign_in accounts 'visitor_1'
    post convert_user_diary_url(users('visitor_1'), diaries(:one))

    assert flash[:alert]
    assert_response :success
  end

  test 'convert diary as admin' do
    post convert_user_diary_url(users('visitor_1'), diaries(:one))

    assert_nil flash[:alert]
    assert_redirected_to redaction_news_url diaries(:one)
  end

  test 'do not move diary' do
    sign_in accounts 'visitor_1'
    post move_user_diary_url users('visitor_1'), diaries(:one), params: {
      post: { forum_id: forums(:one).id }
    }

    assert_response :success
  end

  test 'move diary' do
    assert_difference 'Diary.all.find_all { |d| d.visible? }.count', -1 do
      assert_difference 'Post.count' do
        post move_user_diary_url users('visitor_1'), diaries(:one), params: {
          post: { forum_id: forums(:one).id }
        }
      end
    end

    assert_redirected_to diaries_url
  end
end
