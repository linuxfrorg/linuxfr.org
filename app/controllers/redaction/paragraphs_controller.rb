# encoding: UTF-8
#
class Redaction::ParagraphsController < RedactionController
  before_action :find_paragraph, except: [:create]

  def create
    @news = News.find(params[:news_id])
    @news.editor = current_account
    enforce_update_permission(@news)
    if @news.paragraphs.in_first_part.count == 0
      paragraphs = @news.paragraphs.in_first_part
    else
      paragraphs = @news.paragraphs.in_second_part
    end
    paragraphs.create(wiki_body: News::DEFAULT_PARAGRAPH, user: current_user)
    render nothing: true
  end

  def show
    render @paragraph
  end

  def edit
    if @paragraph.lock_by(current_user)
      render partial: 'form'
    else
      render status: :forbidden, text: "Désolé, #{@paragraph.locker} est déjà en train de modifier ce paragraphe !"
    end
  end

  def update
    @paragraph.attributes = paragraph_params
    @paragraph.update_by(current_user)
    render @paragraph
  end

  def unlock
    @paragraph.unlock
    render nothing: true
  end

protected

  def paragraph_params
    params.require(:paragraph).permit(:wiki_body)
  end

  def find_paragraph
    @paragraph = Paragraph.find(params[:id])
    @news = @paragraph.try(:news)
    enforce_update_permission(@news)
  end

end
