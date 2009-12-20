class Redaction::NewsController < RedactionController

  def index
    @news = News.draft.sorted
  end

  def create
    @news = News.new
    @news.title = "Nouvelle dépêche #{News.maximum :id}"
    @news.section = Section.published.first
    @news.wiki_body = @news.wiki_second_part = "Vous pouvez éditer cette partie en cliquant dessus !"
    @news.author_name  = current_user.name
    @news.author_email = current_user.email
    @news.save
    @news.create_node(:public => false, :user_id => (current_user && current_user.id))
    redirect_to [:redaction, @news]
  end

  def show
    @news   = News.find(params[:id])
    @boards = @news.boards
    respond_to do |wants|
      wants.html {
        redirect_to [:redaction, @news], :status => 301 and return if @news.has_better_id?
        render :show, :layout => 'chat_n_edit'
      }
      wants.js { render :partial => 'short' }
    end
  end

  def edit
    @news = News.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @news && @news.editable_by?(current_user)
    respond_to do |wants|
      wants.js { render :partial => 'form' }
    end
  end

  def update
    @news = News.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @news && @news.editable_by?(current_user)
    @news.attributes = params[:news]
    @news.editor_id = current_user.id
    @news.save
    respond_to do |wants|
      wants.js { render :nothing => true }
    end
  end

end
