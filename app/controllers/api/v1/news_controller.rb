class Api::V1::NewsController < Api::V1::ApiController
  before_action -> { doorkeeper_authorize! :news }

  def create
    news = News.new
    news.attributes = news_params
    news.cc_licensed = true
    news.author_name  = current_resource_owner.name
    news.author_email = current_resource_owner.email
    if news.save
      news.submitted_at = DateTime.now
      news.submit!
      render json: news
    else
      render json: { error: news.errors }
    end
  end

protected

  def news_params
    params.permit(:title, :section_id, :message, :wiki_body, :wiki_second_part,
                  links_attributes: [Link::Accessible])
  end
end
