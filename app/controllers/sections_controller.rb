class SectionsController < ApplicationController

  def index
    @sections = Section.published
  end

  def show
    @sections = Section.published
    @order    = params[:order]
    @order    = "created_at" unless VALID_ORDERS.include?(@order)
    @section  = Section.find(params[:id])
    @news     = @section.news.with_node_ordered_by(@order).page(params[:page])
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

end
