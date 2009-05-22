class AccountsController < ApplicationController
  before_filter :anonymous_required, :only => [:new, :create, :activate]
  before_filter :user_required,    :except => [:new, :create, :activate]

  def new
    @account = Account.new
  end
 
  def create
    @account = Account.new(params[:account])
    if @account.save
      flash[:notice] = "Votre compte a été créé. Vous allez recevoir un email avec les informations pour l'activer"
      redirect_to '/'
    else
      render :new
    end
  end

  def activate
    @account = Account.find_using_perishable_token(params[:code], 24.hours)
    if @account && @account.activate!
      flash[:notice] = 'Votre compte a bien été activé'
    else
      flash[:error] = "Désolé, le lien d'activation n'est pas valide"
    end
    redirect_to '/'
  end

  def edit
  end

  def update
  end

  # TODO
  def destroy
  end

end
