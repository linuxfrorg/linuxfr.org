class LinksController < ApplicationController
  before_filter :user_required, :only => [:new, :create, :edit, :update]
  before_filter :new_link,      :only => [:new, :create]
  before_filter :find_link,     :only => [:edit, :update]

  def show
    @link = Link.find(params[:id])
    redirect_to @link ? @link.hit : '/'
  end

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
    render :partial => 'form'
  end

  def update
    @link.attributes = params[:link]
    @link.user_id = current_user.id
    if @link.url.blank?
      @link.destroy
    else
      @link.save
    end
    render :nothing => true
  end

protected

  def new_link
    @news = News.find(params[:news_id])
    @link = @news.links.new
    raise ActiveRecord::RecordNotFound unless @news && @news.editable_by?(current_user)
  end

  def find_link
    @link = Link.find(params[:id])
    @news = @link.news
    raise ActiveRecord::RecordNotFound unless @news && @news.editable_by?(current_user)
  end

end
