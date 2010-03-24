# == Schema Information
#
# Table name: accounts
#
#  id                   :integer(4)      not null, primary key
#  user_id              :integer(4)
#  login                :string(40)      not null
#  state                :string(255)     default("passive"), not null
#  karma                :integer(4)      default(20), not null
#  nb_votes             :integer(4)      default(0), not null
#  stylesheet           :string(255)
#  old_password         :string(20)
#  email                :string(255)     not null
#  encrypted_password   :string(40)      not null
#  password_salt        :string(255)     not null
#  confirmation_token   :string(20)
#  confirmed_at         :datetime
#  confirmation_sent_at :datetime
#  reset_password_token :string(20)
#  remember_token       :string(20)
#  remember_created_at  :datetime
#  sign_in_count        :integer(4)
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  current_sign_in_ip   :string(255)
#  last_sign_in_ip      :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#

class Account < ActiveRecord::Base
  include AASM

  belongs_to :user, :inverse_of => :account
  accepts_nested_attributes_for :user, :reject_if => proc { |attrs| attrs['user'].blank? }

  attr_accessible :login, :email, :stylesheet, :password, :password_confirmation, :user_attributes

### Authentication ###

  devise :registerable, :authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

### Validation ###

  validates_presence_of :login, :message => "Veuillez choisir un pseudo"
  validates_uniqueness_of :login, :message => "Ce pseudo est déjà pris"

### Password ###

  before_validation :generate_a_password, :on => :create
  def generate_a_password
    chars = [*'A'..'Z'] + [*'a'..'z'] + [*'1'..'9'] + %w(- + ! ? : £ $ % &)
    pass  = (0..7).map { chars.rand }.join
    self.password = self.password_confirmation = pass
  end

  # Try to import the password from templeet
  def self.try_import_old_password(credentials)
    login      = credentials[:login]
    password   = credentials[:password]
    account    = Account.where(:login => login).where("ENCRYPT(?, old_password) = old_password", password).first
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
    nodes       = Node.where(:user_id => self.id)
    yesterday   = [DateTime.yesterday.beginning_of_day, DateTime.yesterday.end_of_day]
    votes       = nodes.join(:votes).where("votes.created_at BETWEEN ? AND ?", *yesterday)
    relevances  = nodes.join(:relevances).where("relevances.created_at BETWEEN ? AND ?", *yesterday)
    self.karma -= votes.where("vote = 0").count
    self.karma += votes.where("vote = 1").count
    self.karma -= relevances.where("vote = 0").count
    self.karma += relevances.where("vote = 1").count
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
