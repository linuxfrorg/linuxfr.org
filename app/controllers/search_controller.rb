class SearchController < ApplicationController
  include SearchHelper

  FACET_BY_TYPE = {
    'news'     => 'section',
    'posts'    => 'forum',
    'trackers' => 'category'
  }

  def index
    @query   = params[:q]
    @query   = "42" if @query.blank?
    @page    = (params[:page] || 1).to_i
    @type    = params[:type]
    @facet   = FACET_BY_TYPE[@type] if @type
    @value   = params[:facet]
    @start   = Time.at(params[:start].to_i).to_date if params[:start].present?
    @order   = params[:order] == "date"
    @query.gsub!(/([&|!^~\\])/, '\\\1')
    @results = search.results
    Rails.logger.info search.to_curl
  rescue Tire::Search::SearchRequestFailed
    @query.gsub!(/([+\-\(\){}\[\]"*?:])/, '\\\1')
    @results = search.results
  end

protected

  def search
    per_page = 15
    periods = [
      { :from => 1.week.ago },
      { :from => 1.month.ago },
      { :from => 1.year.ago },
    ]
    indexes = @type || "diaries,news,polls,posts,trackers,wiki_pages,pages"
    Tire.search(indexes) do |s|
      s.query do |q|
        q.boolean do |b|
          b.must { |m| m.string @query }
          b.must { |m| m.string "#{@facet}:#{@value}" } if @value
          b.must { |m| m.string "created_at:[#{@start} TO #{Date.tomorrow}]" } if @start
        end
      end
      s.sort { by :created_at, 'desc' } if @order
      s.size per_page
      s.from (@page - 1) * per_page
      s.facet('periods') { |f| f.range :created_at, periods } unless @start
      s.facet('types') { |f| f.terms :_index } unless @type
      s.facet(@facet) { |f| f.terms @facet } if @facet
    end
  end

end
