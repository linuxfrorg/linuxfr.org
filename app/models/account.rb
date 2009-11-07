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
#  stylesheet          :string(255)
#  old_password        :string(20)
#  karma               :integer(4)      default(20), not null
#  nb_votes            :integer(4)      default(0), not null
#  created_at          :datetime
#  updated_at          :datetime
#

class Account < ActiveRecord::Base
  include AASM

  belongs_to :user
  accepts_nested_attributes_for :user, :reject_if => proc { |attrs| attrs['user'].blank? }

  attr_accessible :login, :email, :stylesheet, :password, :password_confirmation, :user_attributes

### Validation ###

  validates_presence_of :login, :message => "Veuillez choisir un pseudo"
  validates_presence_of :email, :message => "Veuillez entrer votre adresse email"

### Authentication ###

  acts_as_authentic do |config|
    config.validates_length_of_login_field_options :within => 3..30, :message => "Le login doit faire au moins 3 caractères, et pas plus de 30 caractères"
    config.validates_uniqueness_of_login_field_options :case_sensitive => true, :message => "Ce login est déjà utilisé, veuillez en choisir un autre"
    config.validates_uniqueness_of_email_field_options :case_sensitive => true, :message => "Cette adresse email est déjà utilisée pour un compte LinuxFr.org"
    config.perishable_token_valid_for 24.hours
  end

### Password ###

  before_validation_on_create :generate_a_password

  def generate_a_password
    chars = [*'A'..'Z'] + [*'a'..'z'] + [*'1'..'9'] + %w(- + ! ? : £ $ % &)
    pass  = (0..7).map { chars.rand }.join
    self.password = self.password_confirmation = pass
  end

  # Try to import the password from templeet
  def self.try_import_old_password(credentials)
    login      = credentials[:login]
    password   = credentials[:password]
    conditions = ["LOGIN = ? AND ENCRYPT(?, old_password) = old_password", login, password]
    account    = Account.first(:conditions => conditions)
    return unless account
    account.password = account.password_confirmation = password
    account.old_password = nil
    account.save
  end

### Workflow ###

  aasm_column :state
  aasm_initial_state :passive

  aasm_state :passive
  aasm_state :active
  aasm_state :deleted

  aasm_event :activate   do transitions :from => [:passive], :to => :active,  :on_transition => :activation   end
  aasm_event :delete     do transitions :from => [:active],  :to => :deleted, :on_transition => :deletion     end
  aasm_event :reactivate do transitions :from => [:deleted], :to => :active,  :on_transition => :reactivation end

  def activation
    user = User.new(:name => login)
    user.account = self
    user.save
    save
  end

  def deletion
    user.inactivate!
  end

  def reactivation
    user.reactivate!
  end

### Karma ###

  def daily_karma
    self.karma -= Vote.count(:conditions => ["nodes.user_id = ? AND (votes.created_at BETWEEN ? AND ?) AND vote = 0",
                                             self.id, DateTime.yesterday.beginning_of_day, DateTime.yesterday.end_of_day],
                             :joins => :node).to_i
    self.karma += Vote.count(:conditions => ["nodes.user_id = ? AND (votes.created_at BETWEEN ? AND ?) AND vote = 1",
                                             self.id, DateTime.yesterday.beginning_of_day, DateTime.yesterday.end_of_day],
                             :joins => :node).to_i
    self.karma -= Relevance.count(:conditions => ["comments.user_id = ? AND (relevances.created_at BETWEEN ? AND ?) AND vote = 0",
                                                  self.id, DateTime.yesterday.beginning_of_day, DateTime.yesterday.end_of_day],
                                  :joins => :comment).to_i
    self.karma += Relevance.count(:conditions => ["comments.user_id = ? AND (relevances.created_at BETWEEN ? AND ?) AND vote = 1",
                                                  self.id, DateTime.yesterday.beginning_of_day, DateTime.yesterday.end_of_day],
                                  :joins => :comment).to_i
    self.nb_votes = 3 + karma / 10
    save
  end

  def give_karma(points)
    self.karma += points
    save
  end

### Presentation ###

  def email_address
    "#{login} <#{email}>"
  end

end
