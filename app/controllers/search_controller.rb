class SearchController < ApplicationController
  FACET_BY_TYPE = {
    'News'    => :section,
    'Post'    => :forum,
    'Tracker' => :category
  }

  def index
    search nil, :type
  end

  def by_type
    @type  = params[:type].constantize
    @facet = FACET_BY_TYPE[params[:type]]
  end

  def by_facet
    @type  = params[:type].constantize
    @facet = nil
  end

protected

  def search(type, facet_term)
    q = params[:q]
    q = "42" if q.blank?
    per_page = 15
    page = (params[:page] || 1).to_i
    @contents = Tire.search("contents") do
      query { string q }
      size per_page
      from (page - 1) * per_page
      facet('types') { terms facet_term } if facet_term
    end.results
  end

end
