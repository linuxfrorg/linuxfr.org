# encoding: utf-8
class SearchController < ApplicationController
  FACET_BY_TYPE = {
    'News'    => :section,
    'Post'    => :forum,
    'Tracker' => :category
  }

  before_filter :get_params, :except => [:google]

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

  GOOGLE_URL = "http://www.google.fr/custom"
  GOOGLE_COF = "AH:center;LP:1;LW:100;LH:100;L:http://linuxfr.org/images/linuxfr2_100.png;S:https://linuxfr.org/;FORID:1;"
  GOOGLE_PUB = "pub-7360553289941628"

  def google
    query = {:cof => GOOGLE_COF, :client => GOOGLE_PUB, :sitesearch => MY_DOMAIN, :domains => MY_DOMAIN, :q => params[:q], :hl => "fr", :forid => 1}
    redirect_to "#{GOOGLE_URL}?#{query.to_query}"
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
