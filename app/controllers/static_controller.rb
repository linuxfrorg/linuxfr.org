class StaticController < ApplicationController

  def proposer_un_contenu_quand_on_est_anonyme
    if current_user
      redirect_to :action => 'proposer_un_contenu'
    else
      @anonymous = true
      render :proposer_un_contenu
    end
  end

  def proposer_un_contenu
    if current_user
      @anonymous = false
    else
      redirect_to :action => 'proposer_un_contenu_quand_on_est_anonyme'
    end
  end

  def team
  end

  def informations
  end

  def contact
    render :team
  end

  def plan
  end

end
