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
  has_many :access_grants, dependent: :delete_all

  validates :name, presence: { message: "Veuillez remplir le nom" }

  before_create :generate_id_and_secret
  def generate_id_and_secret
    self.app_id     = SecureRandom.hex(16)
    self.app_secret = SecureRandom.hex(16)
  end

  def self.authenticate(app_id, app_secret)
    find_by(app_id: app_id, app_secret: app_secret)
  end
end
