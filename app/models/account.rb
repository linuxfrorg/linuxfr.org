# encoding: UTF-8
#
# == Schema Information
#
# Table name: accounts
#
#  id                   :integer(4)      not null, primary key
#  user_id              :integer(4)
#  login                :string(40)      not null
#  role                 :string(10)      default("moule"), not null
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
#  preferences          :integer(4)      default(0), not null
#

# The accounts are the private informations about users.
# A user wth an account can login, change its password
# and do many other things on the site.
#
# There are several levels of users:
#   * anonymous     -> they have no account and can only read public contents
#   * authenticated -> they can read public contents and submit new ones
#   * reviewer      -> they can review the news while they are in moderation
#   * moderator     -> they makes the order and the security ruling
#   * admin         -> the almighty users
#
class Account < ActiveRecord::Base
  include Canable::Cans

  belongs_to :user, :inverse_of => :account
  accepts_nested_attributes_for :user, :reject_if => :all_blank

  attr_accessor :remember_me
  attr_accessible :login, :email, :stylesheet, :password, :password_confirmation, :user_attributes, :remember_me
  delegate :name, :to => :user

  scope :unconfirmed, where(:confirmed_at => nil)

### Authentication ###

  devise :registerable, :database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable

  before_create :create_user
  def create_user
    self.user_id = User.create(:name => login, :gravatar_hash => gravatar_hash).id
  end

  after_validation :update_gravatar_hash, :on => :update
  def update_gravatar_hash
    user.update_attribute(:gravatar_hash, gravatar_hash) if email_changed?
  end

  def gravatar_hash
    Digest::MD5.hexdigest(email.downcase.strip)
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

  EMAIL_REGEXP = RUBY_VERSION.starts_with?('1.8') ? /^.+@.+\.\w{2,4}$/i : /^[\p{Word}.%+\-]+@[\p{Word}.\-]+\.[\w]{2,}$/i
  validates :email, :presence   => { :message => "Veuillez remplir l'adresse de courriel" },
                    :uniqueness => { :message => "Cette adresse de courriel est déjà utilisée", :case_sensitive => false, :allow_blank => true },
                    :format     => { :message => "L'adresse de courriel n'est pas valide", :with => EMAIL_REGEXP, :allow_blank => true }

  validates :password, :presence     => { :message => "Le mot de passe est absent", :on => :create },
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

  def update_with_password(params={})
    current_password = params.delete(:current_password)

    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
      return update_attributes(params)
    end

    result = if valid_password?(current_password)
      update_attributes(params)
    else
      self.errors.add(:current_password, "Mot de passe invalide")
      self.attributes = params
      false
    end

    clean_up_passwords
    result
  end

### Role ###

  scope :reviewer,  where(:role => "reviewer")
  scope :moderator, where(:role => "moderator")
  scope :admin,     where(:role => "admin")
  scope :amr,       where(:role => %w[admin moderator reviewer])

  state_machine :role, :initial => :moule do
    event :inactivate            do transition all                 => :inactive  end
    event :reactivate            do transition :inactive           => :moule     end
    event :give_writer_rights    do transition [:moule, :reviewer] => :writer    end
    event :give_reviewer_rights  do transition all - :inactive     => :reviewer  end
    event :give_moderator_rights do transition [:reviewer, :admin] => :moderator end
    event :give_admin_rights     do transition :moderator          => :admin     end
  end

  # An AMR is someone who is either an admin, a moderator or a reviewer
  def amr?
    admin? || moderator? || reviewer?
  end

  def active?
    super && role != 'inactive'
  end

  alias :destroy :inactivate!

  def self.send_reset_password_instructions(attributes={})
    user = find_or_initialize_with_error_by(:email, attributes[:email], :not_found)
    user.send_reset_password_instructions if user.persisted? && user.active?
    user
  end

### Actions ###

  def can_post_on_board?
    active?
  end

  def tag(node, tags)
    node.set_taglist(tags, user_id)
  end

  def read(node)
    node.read_by(self.id)
  end

  def viewable_by?(account)
    account && (account.admin? || account.moderator? || account.id == self.id)
  end

### Karma ###

  def daily_karma
    self.karma += $redis.get("users/#{self.user_id}/diff_karma").to_i
    $redis.del("users/#{self.user_id}/diff_karma")
    self.nb_votes = [3 + karma / 10, 100].min
    save
  end

  def give_karma(points)
    self.karma += points
    save
  end

  def nb_votes
    [self["nb_votes"], 0].max
  end

### Preferences ###

  include Bitfields
  bitfield :preferences,   1 => :hide_avatar,
                           2 => :news_on_home,
                           4 => :diaries_on_home,
                           8 => :posts_on_home,
                          16 => :polls_on_home,
                          32 => :wiki_pages_on_home,
                          64 => :trackers_on_home,
                         128 => :sort_by_date_on_home,
                         :scopes => false
  attr_accessible :hide_avatar, :news_on_home, :diaries_on_home, :posts_on_home, :polls_on_home, :wiki_pages_on_home, :trackers_on_home, :sort_by_date_on_home

  def types_on_home
    %w(News Diary Post Poll WikiPage Tracker).select do |type|
      send "#{type.tableize}_on_home?"
    end
  end
end
