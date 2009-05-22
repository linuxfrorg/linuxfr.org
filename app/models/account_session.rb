class AccountSession < Authlogic::Session::Base

  def user
    account.user
  end

end
