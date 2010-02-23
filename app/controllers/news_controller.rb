class NewsController < ApplicationController
  after_filter  :marked_as_read, :only => [:show]
  respond_to :html, :atom

  def index
    @order = params[:order] ? "nodes.#{params[:order]}" : 'news.created_at'
    @news  = News.published.joins(:node).order("#{@order} DESC").paginate(:page => params[:page], :per_page => 10)
    respond_with(@news)
  end

  def show
    @news = News.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @news && @news.readable_by?(current_user)
    # TODO Rails 3
    # redirect_to @news, :status => 301 if @news.has_better_id?
    respond_with(@news)
  end

  # It's exactly the same thing that show, but only for anonymous users.
  # So we can safely cache it.
  # TODO factorize code
  def anonymous
    @news = News.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @news && @news.readable_by?(current_user)
    # TODO Rails 3
    # redirect_to @news, :status => 301 if @news.has_better_id?
    render :show
  end

  def new
    @news = News.new
  end

  def create
    @news = News.new
    @news.attributes   = params[:news]
    @news.author_name  = current_user.name  if current_user
    @news.author_email = current_user.email if current_user
    if !preview_mode && @news.save
      @news.create_node(:public => false, :user_id => (current_user && current_user.id))
      @news.submit!
      redirect_to news_index_url, :notice => "Votre proposition de dépêche a bien été soumise, et sera modérée dans les heures ou jours à venir"
    else
      @news.node = Node.new
      render :new
    end
  end

protected

  def marked_as_read
    current_user.read(@news.node) if current_user
  end

end
