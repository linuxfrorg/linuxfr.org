# encoding: UTF-8
class Moderation::ImagesController < ModerationController

  def index
    @images = Image.latest(20)
  end

  def destroy
    unless params[:id].blank?
      Board.amr_notification("Une image récente de #{moderation_images_url} a été bloquée par #{current_user.name} #{user_url(current_user)}")
      Image.destroy params[:id]
    end
    redirect_to moderation_images_url
  end
end
