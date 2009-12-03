class ParagraphsController < ApplicationController
  before_filter :user_required
  before_filter :find_paragraph

  def show
    if @news && @news.editable_by?(current_user)
      render @paragraph
    else
      render :nothing => true
    end
  end

  def edit
    raise ActiveRecord::RecordNotFound unless @news && @news.editable_by?(current_user)
    render :partial => 'form'
  end

  def update
    raise ActiveRecord::RecordNotFound unless @news && @news.editable_by?(current_user)
    @paragraph.attributes = params[:paragraph]
    @paragraph.user_id = current_user.id
    if @paragraph.wiki_body.blank?
      @paragraph.destroy
    else
      @paragraph.save
    end
    render :nothing => true
  end

protected

  def find_paragraph
    @paragraph = Paragraph.find_by_id(params[:id])
    @news = @paragraph.try(:news)
  end

end
