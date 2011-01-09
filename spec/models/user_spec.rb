# == Schema Information
#
# Table name: users
#
#  id                  :integer(4)      not null, primary key
#  name                :string(32)
#  homesite            :string(100)
#  jabber_id           :string(32)
#  cached_slug         :string(32)
#  avatar_file_name    :string(255)
#  avatar_content_type :string(255)
#  avatar_file_size    :integer(4)
#  avatar_updated_at   :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  gravatar_hash       :string(32)
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
