class SearchController < ApplicationController

  def index
    q = params[:q]
    q = "42" if q.blank?
    per_page = 15
    page = (params[:page] || 1).to_i
    @contents = Tire.search("contents") do
      query { string q }
      size per_page
      from (page - 1) * per_page
      highlight :title, :body, :options => { :tag => '<mark class="highlight">' }
    end.results
  end

end
