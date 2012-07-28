# encoding: utf-8
# == Schema Information
#
# Table name: accounts
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  login                  :string(40)       not null
#  role                   :string(10)       default("visitor"), not null
#  karma                  :integer          default(20), not null
#  nb_votes               :integer          default(0), not null
#  stylesheet             :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(128)      default(""), not null
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  reset_password_token   :string(255)
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  preferences            :integer          default(0), not null
#  reset_password_sent_at :datetime
#  min_karma              :integer          default(20)
#  max_karma              :integer          default(20)
#

require 'spec_helper'

describe Account do
  before(:each) do
    Account.delete_all
  end

  it "is valid" do
    FactoryGirl.build(:normal_account).should be_valid
  end

  it "has a valid password" do
    FactoryGirl.create(:normal_account).should be_valid_password('I<3J2EE')
  end
end
