class StylesheetsController < ApplicationController
  before_filter :authenticate_account!
  before_filter :load_account

  def edit
    @stylesheets = Stylesheet.all
    @current = @account.stylesheet
  end

  def create
    @account.stylesheet = params[:stylesheet]
    @account.save
    redirect_to edit_stylesheet_url, :notice => "Feuille de style enregistrée"
  end

  def destroy
    @account.stylesheet = nil
    @account.save
    redirect_to edit_stylesheet_url, :notice => "Feuille de style par défaut"
  end

protected

  def load_account
    @account = current_account
  end

end
