class StylesheetsController < ApplicationController
  before_filter :user_required

  def edit
    @stylesheets = Stylesheet.all
    @current = current_account_session.stylesheet
  end

  def create
    account = current_account_session.account
    account.stylesheet = params[:stylesheet]
    account.save
    flash[:success] = "Feuille de style enregistrée"
    redirect_to edit_account_stylesheet_url
  end

  def destroy
    account = current_account_session.account
    account.stylesheet = nil
    account.save
    flash[:success] = "Feuille de style par défaut"
    redirect_to edit_account_stylesheet_url
  end

end
