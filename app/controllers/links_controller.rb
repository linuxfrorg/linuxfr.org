class LinksController < ApplicationController

  def show
    link = Link.find(params[:id])
    if link
      link.hit
      redirect_to link.url
    else
      redirect_to '/'
    end
  end

end
