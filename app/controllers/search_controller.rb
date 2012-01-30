class SearchController < ApplicationController
  include SearchHelper

  FACET_BY_TYPE = {
    'News'    => 'section',
    'Post'    => 'forum',
    'Tracker' => 'category'
  }

  def index
    search
  end

  def by_type
    @type  = params[:type]
    @facet = FACET_BY_TYPE[es_facet_to_class(params[:type]).name]
    search @type, @facet
  end

  def by_facet
    @type  = es_facet_to_class(params[:type])
    @facet = FACET_BY_TYPE[params[:type]]
    search @type, @facet
  end

protected

  def search(type=nil, facet_term=nil)
    q = params[:q]
    q = "42" if q.blank?
    per_page = 15
    page = (params[:page] || 1).to_i
    @contents = Tire.search("contents") do
      query do
        boolean do
          must { string q }
          must { string "type:#{type}" } if type
        end
      end
      size per_page
      from (page - 1) * per_page
      facet('types') { terms :type }
      facet(facet_term) { terms facet_term } if facet_term
    end.results
  end

end
