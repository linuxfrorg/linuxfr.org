# encoding: UTF-8
#
# == Schema Information
#
# Table name: accounts
#
#  id                   :integer(4)      not null, primary key
#  user_id              :integer(4)
#  login                :string(40)      not null
#  karma                :integer(4)      default(20), not null
#  nb_votes             :integer(4)      default(0), not null
#  stylesheet           :string(255)
#  old_password         :string(20)
#  email                :string(255)     default(""), not null
#  encrypted_password   :string(128)     default(""), not null
#  password_salt        :string(255)     default(""), not null
#  confirmation_token   :string(255)
#  confirmed_at         :datetime
#  confirmation_sent_at :datetime
#  reset_password_token :string(255)
#  remember_token       :string(255)
#  remember_created_at  :datetime
#  sign_in_count        :integer(4)      default(0)
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  current_sign_in_ip   :string(255)
#  last_sign_in_ip      :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#

class Account < ActiveRecord::Base
  belongs_to :user, :inverse_of => :account
  accepts_nested_attributes_for :user, :reject_if => proc { |attrs| attrs['user'].blank? }

  attr_accessor :remember_me
  attr_accessible :login, :email, :stylesheet, :password, :password_confirmation, :user_attributes, :remember_me

  scope :unconfirmed, where(:confirmed_at => nil)

### Authentication ###

  devise :registerable, :database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable

  before_create :create_user
  def create_user
    self.user_id = User.create(:name => login).id
  end

  # First, we try the normal password,
  # but, if it fails, we also try the old_password from before the migration
  # and if this old_password is good, we migrate to the new password encryption.
  def valid_password?(incoming_password)
    return true if super(incoming_password)
    return false if incoming_password.blank? || old_password.blank?
    if incoming_password.crypt(old_password) == old_password
      self.password = self.password_confirmation = incoming_password
      self.old_password = nil
      save(:validate => false)
      return true
    end
    false
  end

### Validation ###

  validates :login, :presence   => { :message => "Veuillez choisir un pseudo"},
                    :uniqueness => { :message => "Ce pseudo est déjà pris" }

  validates :email, :presence   => { :message => "Veuillez remplir l'adresse de courriel" },
                    :uniqueness => { :message => "Cette adresse de courriel est déjà utilisée", :case_sensitive => false, :allow_blank => true },
                    :format     => { :message => "L'adresse de courriel n'est pas valide", :with => /^[\p{Word}.%+\-]+@[\p{Word}.\-]+\.[\w]{2,}$/i, :allow_blank => true }

  validates :password, :presence     => { :message => "Le mot de passe est absent" },
                       :confirmation => { :message => "La confirmation du mot de passe ne correspond pas au mot de passe" }

### Password ###

  before_validation :generate_a_password, :on => :create
  def generate_a_password
    chars = [*'A'..'Z'] + [*'a'..'z'] + [*'1'..'9'] + %w(- + ! ? : $ % &)
    pass  = chars.sample(8).join
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

### Karma ###

  def daily_karma
    self.karma += $redis.get("users/#{self.user_id}/diff_karma").to_i
    $redis.del("users/#{self.user_id}/diff_karma")
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
