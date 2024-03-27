# encoding: UTF-8
class Moderation::PlonkController < ModerationController
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper

  def create
    nb_days  = (params[:nb_days] || 2).to_i
    @account = Account.find(params[:account_id])
    @account.plonk(nb_days, current_user.id)
    if nb_days > 0
      Board.amr_notification("Le compte #{@account.login} #{user_url @account.login} a été privé de tribune pendant #{pluralize nb_days, "jour"} par #{current_user.name} #{user_url(current_user)}")
      render json: { notice: "#{@account.login} a été privé de tribune pendant #{pluralize nb_days, "jour"}" }
    else
      Board.amr_notification("Le compte #{@account.login} #{user_url @account.login} a été réautorisé sur la tribune par #{current_user.name} #{user_url(current_user)}")
      render json: { notice: "#{@account.login} a été réautorisé sur la tribune" }
    end
  end
end
