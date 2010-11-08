# == Schema Information
#
# Table name: users
#
#  id                  :integer(4)      not null, primary key
#  name                :string(100)
#  homesite            :string(255)
#  jabber_id           :string(255)
#  role                :string(255)     default("moule"), not null
#  cached_slug         :string(255)
#  avatar_file_name    :string(255)
#  avatar_content_type :string(255)
#  avatar_file_size    :integer(4)
#  avatar_updated_at   :datetime
#  created_at          :datetime
#  updated_at          :datetime
#

require 'spec_helper'

describe User do
  before(:each) do
    User.delete_all
    Account.delete_all
  end

  it "has an account" do
    user = Factory(:user)
    user.account.should be
  end
end
