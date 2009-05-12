class AccountSession < Authlogic::Session::Base

  def user
    account.find(:include => [:user]).user
  end

end
