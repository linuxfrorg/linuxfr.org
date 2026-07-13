class SearchController < ApplicationController

  def index
    params.permit!
    redirect_to "https://www.mojeek.com/search?#{params.slice(:q).to_query}+site%3Alinuxfr.org"
  end

end
