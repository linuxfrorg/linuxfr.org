class SectionsController < ApplicationController

  def index
    @sections = Section.published
  end

  def show
    @section  = Section.find(params[:id])
    redirect_to @section, :status => 301 and return if !@section.friendly_id_status.best?
    @sections = Section.published
    @order    = params[:order]
    @order    = "created_at" unless VALID_ORDERS.include?(@order)
    @news     = @section.news.with_node_ordered_by(@order).page(params[:page])
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

end
