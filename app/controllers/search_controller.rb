class SearchController < ApplicationController
  include SearchHelper

  FACET_BY_TYPE = {
    'News'    => 'section',
    'Post'    => 'forum',
    'Tracker' => 'category'
  }

  def index
    @query   = params[:q]
    @query   = "42" if @query.blank?
    @page    = (params[:page] || 1).to_i
    @type    = params[:type]
    @facet   = FACET_BY_TYPE[es_facet_to_class(params[:type]).name] if @type
    @value   = params[:facet]
    @results = search.results
  end

protected

  def search
    per_page = 15
    periods = [
      { :from => 1.week.ago },
      { :from => 1.month.ago },
      { :from => 1.year.ago },
      {}
    ]
    Tire.search("contents") do |s|
      s.query do |q|
        q.boolean do |b|
          b.must { |m| m.string @query }
          b.must { |m| m.string "type:#{@type}" } if @type
          b.must { |m| m.string "#{@facet}:#{@value}" } if @value
        end
      end
      s.size per_page
      s.from (@page - 1) * per_page
      s.facet('periods') { |f| f.range :created_at, periods }
      s.facet('types') { |f| f.terms :type }
      s.facet(@facet) { |f| f.terms @facet } if @facet
    end
  end

end
