class SearchController < ApplicationController

  def index
    @search = Search.new
    @search.query = params[:q]
    @search.query = "42" if @search.query.blank?
    @search.page  = (params[:page] || 1).to_i
    @search.type  = params[:type]
    @search.value = params[:facet]
    @search.start = Time.at(params[:start].to_i).to_date if params[:start].present?
    @search.order = params[:order]
    @search.run
  end

end
