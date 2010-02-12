class SearchController < ApplicationController
  FACET_BY_TYPE = {
    'News'    => :section,
    'Post'    => :forum,
    'Tracker' => :category
  }

  before_filter :get_params

  def index
    @results = ThinkingSphinx::Search.search(@query + '*', :page => params[:page], :per_page => 10)
    @facets  = ThinkingSphinx::Search.facets(@query + '*')[:class]
  end

  def type
    @results = @type.search(@query + '*', :page => params[:page], :per_page => 10)
    @facets  = @type.facets(@query + '*')[@facet]
    render :index
  end

  def facet
    by_facet = @type.facets(@query + '*', :page => params[:page], :per_page => 10)
    @results = by_facet.for(@facet => params[:facet])
    render :index
  end

protected

  def get_params
    @query = params[:q].to_s
    if params[:type].present?
      @type  = params[:type].constantize
      @facet = FACET_BY_TYPE[params[:type]]
    else
      @facet = 'default'
    end
  end

end
