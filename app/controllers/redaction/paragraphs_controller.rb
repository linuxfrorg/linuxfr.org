# encoding: UTF-8
#
class Redaction::ParagraphsController < RedactionController
  before_filter :find_paragraph, :except => [:create]

  def create
    @news = News.find(params[:news_id])
    enforce_update_permission(@news)
    if @news.paragraphs.in_first_part.count == 0
      paragraphs = @news.paragraphs.in_first_part
    else
      paragraphs = @news.paragraphs.in_second_part
    end
    paragraphs.create(:wiki_body => "Vous pouvez éditer ce paragraphe en cliquant dessus", :user => current_user)
  end

  def show
    render @paragraph
  end

  def edit
    if @paragraph.lock_by(current_user)
      render :partial => 'form'
    else
      render @paragraph
    end
  end

  def update
    @paragraph.attributes = params[:paragraph]
    @paragraph.update_by(current_user)
    render :nothing => true
  end

protected

  def find_paragraph
    @paragraph = Paragraph.find_by_id(params[:id])
    @news = @paragraph.try(:news)
    enforce_update_permission(@news)
  end

end
