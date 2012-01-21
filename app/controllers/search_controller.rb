class SearchController < ApplicationController

  def index
    @contents = Diary.search(params[:q], :page => params[:page], :load => true)
  end

end
