class AccountSession < Authlogic::Session::Base

  delegate :user, :stylesheet, :to => :account

end
