class Redaction::ParagraphsController < RedactionController
  before_filter :find_paragraph

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
