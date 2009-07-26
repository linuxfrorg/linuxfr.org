class SectionsController < ApplicationController

  def index
    @sections = Section.published
  end

  def show
    @order   = params[:order] || 'created_at'
    @section = Section.find(params[:id])
    @news    = @section.news.published.paginate(:page => params[:page], :per_page => 10, :order => "nodes.#{@order} DESC", :joins => :node)
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

end
