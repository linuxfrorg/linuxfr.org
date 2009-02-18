class StaticController < ApplicationController

  def proposer_un_contenu_quand_on_est_anonyme
    @anonymous = true
    render :proposer_un_contenu
  end

  def proposer_un_contenu
    @anonymous = false
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
