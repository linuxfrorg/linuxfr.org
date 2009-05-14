# == Schema Information
# Schema version: 20090505233940
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

class Account < ActiveRecord::Base
  include AASM

  belongs_to :user

### Authentication ###

  acts_as_authentic do |config|
    config.validates_length_of_login_field_options :within => 2..100
    config.validates_uniqueness_of_login_field_options :case_sensitive => true
  end

### Workflow ###

  aasm_column :state
  aasm_initial_state :passive

  aasm_state :passive
  aasm_state :active
  aasm_state :deleted

  aasm_event :activate do transitions :from => [:passive], :to => :active,  :on_transition => :activation end
  aasm_event :delete   do transitions :from => [:active],  :to => :deleted, :on_transition => :deletion   end

  def activation
    self.user.create(:name => self.login)
  end

  def deletion
    self.user.inactivate!
  end

end
