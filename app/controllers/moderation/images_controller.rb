# encoding: UTF-8
class Moderation::ImagesController < ModerationController

  def index
    @images = Image.latest(20)
  end

  def destroy
    Image.destroy params[:id] unless params[:id].blank?
    redirect_to moderation_images_url
  end
end
