require 'test_helper'

class DiariesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'get index' do
    get diaries_url
    assert_response :success
  end

  test 'get show' do
    get user_diary_url(users('visitor_1'), diaries(:lorem_cc_licensed), format: :html)
    assert_response :success
    assert_nil flash[:alert]
  end

  test 'get new' do
    sign_in accounts 'maintainer_0'
    get new_diary_url
    assert_response :success
  end

  test 'preview diary' do
    sign_in accounts 'maintainer_0'
    assert_no_difference('Diary.count') do
      post diaries_url,
           params: {
             diary: {
               title: 'Hello world',
               body: 'et le reste',
               wiki_body: 'et le reste',
               truncated_body: 'et le reste'
             },
             tags: 'foo, bar',
             commit: 'Prévisualiser'
           }
    end
    assert_response :success
  end

  test 'create diary' do
    sign_in accounts 'maintainer_0'
    assert_difference('Diary.count') do
      post diaries_url,
           params: {
             diary: {
               title: 'Hello world',
               body: 'et le reste',
               wiki_body: 'et le reste',
               truncated_body: 'et le reste',
               lang: 'fr'
             },
             tags: 'foo, bar'
           }
    end
    assert_redirected_to user_diary_url(users('maintainer_0'), Diary.last)
  end

  test 'get edit' do
    sign_in accounts 'maintainer_0'
    get edit_user_diary_url(users('editor_0'), diaries(:lorem_cc_licensed))
    assert_redirected_to user_diary_url(users('visitor_2'), Diary.last)
  end

  test 'update diary' do
    sign_in accounts 'maintainer_0'
    patch user_diary_url(users('editor_0'), diaries(:lorem_cc_licensed)),
          params: {
            diary: {
              title: 'Nouveau titre'
            }
          }
    assert_redirected_to user_diary_url(users('visitor_2'), diaries(:lorem_cc_licensed))
  end

  test 'destroy diary' do
    sign_in accounts 'admin_0'
    assert_difference('Diary.all.find_all { |d| d.visible? }.count', -1) do
      delete user_diary_url(users('visitor_2'), diaries(:lorem_cc_licensed))
      assert_nil flash[:alert]
      assert_not_nil flash[:notice]
    end
    assert_redirected_to diaries_url
  end

  test 'convert diary' do
    sign_in accounts 'maintainer_0'
    post convert_user_diary_url(users('visitor_2'), diaries(:one))
    assert_nil flash[:alert]
    assert_redirected_to user_diary_url(users('visitor_1'), diaries(:one))
  end

  test 'move diary' do
    sign_in accounts 'admin_0'
    post move_user_diary_url(users('visitor_2'), diaries(:one)),
         params: {
           post: {
             forum_id: forums(:one).id,
             title: 'Nouveau titre',
             cached_slud: 'nouveau-titre'
           }
         }
    assert_nil flash[:alert]
    assert_redirected_to user_diary_url(users('visitor_1'), diaries(:one))
  end
end
