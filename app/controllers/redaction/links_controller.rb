class Redaction::LinksController < RedactionController
  before_filter :new_link,  :only => [:new, :create]
  before_filter :find_link, :only => [:edit, :update]

  def new
    render :partial => 'form'
  end

  def create
    @link.attributes = params[:link]
    @link.user_id = current_user.id
    @link.save
    render :nothing => true
  end

  def edit
    if @link.lock_by(current_user)
      render :partial => 'form'
    else
      render @link
    end
  end

  def update
    @link.attributes = params[:link]
    @link.update_by(current_user)
    render :nothing => true
  end

protected

  def new_link
    @news = News.find(params[:news_id])
    @link = @news.links.new
    enforce_update_permission(@news)
  end

  def find_link
    @link = Link.find(params[:id])
    @news = @link.news
    enforce_update_permission(@news)
  end

end
