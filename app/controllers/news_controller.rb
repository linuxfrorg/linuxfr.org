class NewsController < ApplicationController

  def index
    @news = News.published.sorted.paginate :page => params[:page], :per_page => 10
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def show
    @news = News.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @news && @news.readable_by?(current_user)
  end

  def new
    @preview_mode = false
    @news = News.new
  end

  def create
    @news = News.new
    @news.attributes = params[:news]
    @preview_mode = (params[:commit] == 'Prévisualiser')
    if !@preview_mode && @news.save
      @news.node = Node.create(:user_id => User.new) #(current_user).id)
      flash[:success] = "Votre proposition de dépêche a bien été soumise, et sera modérée dans les heures ou jours à venir"
      redirect_to news_index_url
    else
      render :new
    end
  end

end
