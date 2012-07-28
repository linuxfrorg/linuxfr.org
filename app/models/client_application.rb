# encoding: utf-8
# == Schema Information
#
# Table name: client_applications
#
#  id         :integer          not null, primary key
#  account_id :integer
#  name       :string(255)
#  app_id     :string(32)
#  app_secret :string(32)
#  created_at :datetime
#  updated_at :datetime
#

class ClientApplication < ActiveRecord::Base
  belongs_to :account
  has_many :access_grants, :dependent => :delete_all

  attr_accessible :name

  before_create :generate_id_and_secret
  def generate_id_and_secret
    self.app_id     = SecureRandom.hex(32)
    self.app_secret = SecureRandom.hex(32)
  end

  def self.authenticate(app_id, app_secret)
    where("app_id = ? AND app_secret = ?", app_id, app_secret).first
  end
end
