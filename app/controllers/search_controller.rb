class SearchController < ApplicationController
  FACET_BY_TYPE = {
    'News'    => :section,
    'Post'    => :forum,
    'Tracker' => :category
  }

  def index
    @query   = params[:query].to_s
    @facet   = 'default'
    @results = ThinkingSphinx::Search.search(@query + '*', :page => params[:page], :per_page => 10)
    @facets  = ThinkingSphinx::Search.facets(@query + '*')[:class]
  end

  def type
    @query   = params[:query].to_s
    @type    = params[:type].constantize
    @facet   = FACET_BY_TYPE[params[:type]]
    @results = @type.search(@query + '*', :page => params[:page], :per_page => 10)
    @facets  = @type.facets(@query + '*')[@facet]
    render :index
  end

  def facet
    @query   = params[:query].to_s
    @type    = params[:type].constantize
    @facet   = FACET_BY_TYPE[params[:type]]
    by_facet = @type.facets(@query + '*', :page => params[:page], :per_page => 10)
    @results = by_facet.for(@facet => params[:facet])
    render :index
  end

end
