class LinksController < ApplicationController

  def show
    link = Link.hit(params[:id]) || root_url
    redirect_to link
  end

end
