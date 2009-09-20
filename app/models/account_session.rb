class AccountSession < Authlogic::Session::Base

  delegate :user, :stylesheet, :to => :account
  remember_me true

end
