require 'test_helper'

class NewsControllerTest < ActionDispatch::IntegrationTest
  test 'should list news' do
    get news_index_url
    assert_response :success
  end

  test 'should get calendar' do
    get '/2016/1/1'
    assert_response :success
  end

  test 'should show news' do
    # For the fixtures configuration
    news(:news).node = nodes(:news)

    get news_url(news(:news), format: :html)
    assert_response :success
    assert_nil flash[:alert]
  end

  test 'should get new' do
    get new_news_url
    assert_response :success
  end

  test 'should preview news' do
    assert_no_difference('News.count') do
      post news_index_url,
           params: {
             news: {
               section_id: sections(:news).id,
               title: 'Hello world',
               cached_slug: 'hello-world',
               author_name: 'John Doe',
               author_email: 'johndoe@example.com',
               wiki_body: 'Partie première',
               wiki_second_part: 'Partie secondaire',
               links_attributes: {
                 '0' => {
                   title: 'Hello world',
                   link: 'http://example.com'
                 }
               }
             },
             tags: 'foo, bar',
             commit: 'Prévisualiser'
           }
      assert_nil flash[:alert]
    end
    assert_response :success
  end

  test 'should create news' do
    assert_difference('News.count') do
      post news_index_url,
           params: {
             news: {
               section_id: sections(:news).id,
               title: 'Hello world',
               cached_slug: 'hello-world',
               author_name: 'John Doe',
               author_email: 'johndoe@example.com',
               wiki_body: 'Partie première',
               wiki_second_part: 'Partie secondaire',
               links_attributes: {
                 '0' => {
                   title: 'Hello world',
                   link: 'http://example.com'
                 }
               }
             },
             tags: 'foo, bar'
           }
      assert_nil flash[:alert]
      assert flash[:notice]
    end
    assert_redirected_to news_index_url
  end
end
