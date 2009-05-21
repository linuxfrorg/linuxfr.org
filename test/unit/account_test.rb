# == Schema Information
#
# Table name: accounts
#
#  id                  :integer(4)      not null, primary key
#  user_id             :integer(4)
#  login               :string(40)      not null
#  email               :string(100)     not null
#  state               :string(255)     default("passive"), not null
#  crypted_password    :string(255)     not null
#  password_salt       :string(255)     not null
#  persistence_token   :string(255)     not null
#  single_access_token :string(255)     not null
#  perishable_token    :string(255)     not null
#  login_count         :integer(4)      default(0), not null
#  failed_login_count  :integer(4)      default(0), not null
#  last_request_at     :datetime
#  current_login_at    :datetime
#  last_login_at       :datetime
#  current_login_ip    :string(255)
#  last_login_ip       :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#

require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
