class Redaction::ParagraphsController < RedactionController
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
    if @paragraph.lock_by(current_user)
      render :partial => 'form'
    else
      render @paragraph
    end
  end

  def update
    raise ActiveRecord::RecordNotFound unless @news && @news.editable_by?(current_user)
    @paragraph.attributes = params[:paragraph]
    @paragraph.update_by(current_user)
    render :nothing => true
  end

protected

  def find_paragraph
    @paragraph = Paragraph.find_by_id(params[:id])
    @news = @paragraph.try(:news)
  end

end
