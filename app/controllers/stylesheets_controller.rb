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
    redirect_to edit_account_stylesheet_url, :notice => "Feuille de style enregistrée"
  end

  def destroy
    account = current_account_session.account
    account.stylesheet = nil
    account.save
    redirect_to edit_account_stylesheet_url, :notice => "Feuille de style par défaut"
  end

end
