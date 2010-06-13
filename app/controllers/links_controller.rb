class LinksController < ApplicationController

  def show
    link = Link.hit(params[:id]) || MY_DOMAIN
    redirect_to link
  end

end
