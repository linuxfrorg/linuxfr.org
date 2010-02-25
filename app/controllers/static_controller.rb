class StaticController < ApplicationController

  def show
    @page = Page.find_by_slug!(params[:id])
  end

  def submit_anonymous
    if current_user
      redirect_to :action => 'proposer_un_contenu'
    else
      @anonymous = true
      render :submit_content
    end
  end

  def submit_content
    if current_user
      @anonymous = false
    else
      redirect_to :action => 'proposer_un_contenu_quand_on_est_anonyme'
    end
  end

  def changelog
    @page    = params[:page].to_i
    per_page = 15
    skip     = per_page * @page
    @commits = `cd #{Rails.root} && git log -n #{per_page} --skip=#{skip} --no-merges`
  end

end
