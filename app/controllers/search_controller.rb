class SearchController < ApplicationController

  def index
    q = params.permit(:q, :utf8).slice(:q).to_query
    redirect_to "https://duckduckgo.com/?#{q}+site%3Alinuxfr.org"
  end

end
