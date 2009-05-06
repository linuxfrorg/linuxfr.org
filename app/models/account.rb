# == Schema Information
# Schema version: 20090505233940
#
# Table name: accounts
#
#  id                  :integer(4)      not null, primary key
#  user_id             :integer(4)
#  login               :string(40)      not null
#  email               :string(100)     not null
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

class Account < ActiveRecord::Base
  belongs_to :user

### Authentication ###

  acts_as_authentic do |config|
    config.validates_length_of_login_field_options :within => 2..100
    config.validates_uniqueness_of_login_field_options :case_sensitive => true
  end

end
