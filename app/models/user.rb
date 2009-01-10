# == Schema Information
# Schema version: 20090106000348
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  login                     :string(40)      not null
#  email                     :string(100)     not null
#  name                      :string(100)
#  homesite                  :string(255)
#  jabber_id                 :string(255)
#  state                     :string(255)     default("passive"), not null
#  salt                      :string(40)
#  remember_token            :string(255)
#  remember_token_expires_at :datetime
#  crypted_password          :string(40)
#  activation_code           :string(40)
#  activated_at              :datetime
#  deleted_at                :datetime
#  created_at                :datetime
#  updated_at                :datetime
#

require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles

  has_many :nodes
  has_many :comments

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  #validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message


  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation


  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_in_state :first, :active, :conditions => {:login => login} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

protected

  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end

end
