# encoding: UTF-8
class Moderation::BlockController < ModerationController
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper

  def create
    nb_days  = (params[:nb_days] || 2).to_i
    @account = Account.find(params[:account_id])
    @account.block(nb_days, current_user.id)
    if nb_days > 0
      Board.amr_notification("Les commentaires de #{@account.login} #{user_url @account.login} ont été bloqués pendant #{pluralize nb_days, "jour"} par #{current_user.name} #{user_url(current_user)}")
      render json: { notice: "Les commentaires de #{@account.login} sont bloqués pendant #{pluralize nb_days, "jour"}" }
    else
      Board.amr_notification("Les commentaires de #{@account.login} #{user_url @account.login} ont été débloqués par #{current_user.name} #{user_url(current_user)}")
      render json: { notice: "Les commentaires de #{@account.login} sont débloqués" }
    end
  end
end
