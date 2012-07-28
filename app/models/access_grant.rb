# encoding: utf-8
# == Schema Information
#
# Table name: access_grants
#
#  id                      :integer          not null, primary key
#  account_id              :integer
#  client_application_id   :integer
#  code                    :string(255)
#  access_token            :string(255)
#  refresh_token           :string(255)
#  access_token_expires_at :datetime
#  created_at              :datetime
#  updated_at              :datetime
#

class AccessGrant < ActiveRecord::Base
  belongs_to :account
  belongs_to :client_application

  before_create :generate_tokens
  def generate_tokens
    self.code          = SecureRandom.hex(16)
    self.access_token  = SecureRandom.hex(16)
    self.refresh_token = SecureRandom.hex(16)
  end

  def as_json
    {
      :access_token  => access_token,
      :refresh_token => refresh_token,
      :expires_in    => Devise.timeout_in.to_i
    }
  end

  def start_expiry_period!
    update_column(:access_token_expires_at, 2.days.from_now)
  end

  def self.authenticate(code, application_id)
    where("code = ? AND client_application_id = ?", code, application_id).first
  end

  def self.prune!
    delete_all(["created_at < ?", 3.days.ago])
  end
end
