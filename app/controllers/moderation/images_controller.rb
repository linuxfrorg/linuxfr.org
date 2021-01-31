# encoding: UTF-8
class Moderation::ImagesController < ModerationController

  def index
    @images = Image.latest(20)
  end

  def destroy
    Board.amr_notification("Une image #{moderation_images_url} a été bloquée par #{current_user.name} #{user_url(current_user)}")
    Image.destroy params[:id] unless params[:id].blank?
    redirect_to moderation_images_url
  end
end
