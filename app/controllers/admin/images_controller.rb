# encoding: UTF-8
class Admin::ImagesController < AdminController

  def index
    @images = Image.blocked(100)
  end
end
