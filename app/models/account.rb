# encoding: UTF-8
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
  include ActionView::Helpers::TextHelper

  has_many :client_applications
  has_many :access_grants, :dependent => :delete_all
  has_many :logs
  belongs_to :user, :inverse_of => :account
  accepts_nested_attributes_for :user, :reject_if => :all_blank

  mount_uploader :uploaded_stylesheet, StylesheetUploader

  attr_accessor :remember_me
  attr_accessible :login, :email, :stylesheet, :uploaded_stylesheet, :password, :password_confirmation, :user_attributes, :remember_me
  delegate :name, :to => :user

  scope :unconfirmed, where(:confirmed_at => nil)

### Validation ###

  LOGIN_REGEXP = /^[\p{Word}.+\-]+$/
  validates :login, :presence   => { :message => "Veuillez choisir un pseudo"},
                    :uniqueness => { :message => "Ce pseudo est déjà pris" },
                    :format     => { :message => "Le pseudo n'est pas valide", :with => LOGIN_REGEXP, :allow_blank => true, :on => :create }

  EMAIL_REGEXP = /^[\p{Word}.%+\-]+@[\p{Word}.\-]+\.[\w]{2,}$/i
  validates :email, :presence   => { :message => "Veuillez remplir l'adresse de courriel" },
                    :uniqueness => { :message => "Cette adresse de courriel est déjà utilisée", :case_sensitive => false, :allow_blank => true },
                    :format     => { :message => "L'adresse de courriel n'est pas valide", :with => EMAIL_REGEXP, :allow_blank => true }

  validates :password, :presence     => { :message => "Le mot de passe est absent", :on => :create },
                       :confirmation => { :message => "La confirmation du mot de passe ne correspond pas au mot de passe" }

### Authentication ###

  devise :registerable, :database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable

  before_create :create_user
  def create_user
    self.user_id = User.create(:name => login).id
  end

### Password ###

  before_validation :generate_a_password, :on => :create
  def generate_a_password
    chars = [*'A'..'Z'] + [*'a'..'z'] + [*'1'..'9'] + %w(- + ! ? : $ % &)
    pass  = chars.sample(8).join
    self.password = self.password_confirmation = pass
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
      logs.create(:description => "Mot de passe modifié")
    else
      self.errors.add(:current_password, "Mot de passe invalide")
      self.attributes = params
      false
    end

    clean_up_passwords
    result
  end

### Role ###

  scope :active,    where("role != 'inactive'")
  scope :reviewer,  where(:role => "reviewer")
  scope :moderator, where(:role => "moderator")
  scope :admin,     where(:role => "admin")
  scope :amr,       where(:role => %w[admin moderator reviewer])

  state_machine :role, :initial => :visitor do
    event :inactivate            do transition all                 => :inactive  end
    event :reactivate            do transition :inactive           => :visitor   end
    event :remove_amr_right      do transition all - :inactive     => :visitor   end
    event :give_reviewer_rights  do transition all - :inactive     => :reviewer  end
    event :give_moderator_rights do transition [:reviewer, :admin] => :moderator end
    event :give_admin_rights     do transition :moderator          => :admin     end
    after_transition :do => :log_role
  end

  def log_role
    logs.create(:description => "Changement de rôle : #{role_was} → #{role}")
  end

  # An AMR is someone who is either an admin, a moderator or a reviewer
  def amr?
    admin? || moderator? || reviewer?
  end

  def active_for_authentication?
    super && role != 'inactive'
  end

  alias :destroy :inactivate!

  def inactive_message
    if role == 'inactive'
      :closed
    else
      super
    end
  end

  def self.send_reset_password_instructions(attributes={})
    recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    if recoverable.role == 'inactive'
      recoverable.errors[:base] << I18n.t("devise.failure.closed")
    elsif recoverable.persisted?
      recoverable.send_reset_password_instructions
    end
    recoverable
  end

### Actions ###

  def viewable_by?(account)
    account && (account.admin? || account.moderator? || account.id == self.id)
  end

  def can_post_on_board?
    active_for_authentication? && !plonked? && karma > 0
  end

  def tag(node, tags)
    node.set_taglist(tags, user_id) unless tags.blank?
  end

  def read(node)
    node.read_by(self.id)
    $redis.srem "dashboard/#{self.id}", node.id
  end

  def notify_answer_on(node_id)
    $redis.sadd "dashboard/#{self.id}", node_id
    $redis.expire "dashboard/#{self.id}", 86400 * 7  # one week
  end

  def has_answers?
    $redis.scard("dashboard/#{self.id}").to_i > 0
  end

  def answers_node_id
    $redis.smembers "dashboard/#{self.id}"
  end

  def reset_answers_notifications
    $redis.del "dashboard/#{self.id}"
  end

### Karma ###

  def update_karma_bounds
    if karma > max_karma
      self.max_karma = karma
    elsif karma < min_karma
      self.min_karma = karma
    end
  end

  def daily_karma
    self.karma += $redis.get("users/#{self.user_id}/diff_karma").to_i
    $redis.del("users/#{self.user_id}/diff_karma")
    self.nb_votes = [3 + karma / 10, 100].min
    update_karma_bounds
    save
  end

  def give_karma(points)
    self.karma += points
    update_karma_bounds
    save
  end

  def nb_votes
    [self["nb_votes"], 0].max
  end

  def log_karma(points, who)
    logs.create(:description => "#{who.login} a donné #{points} points de karma")
  end

### Plonk for the board ###

  def plonked?
    $redis.exists("plonk/#{self.id}")
  end

  def plonk(nb_days, user_id)
    $redis.set("plonk/#{self.id}", 1)
    $redis.expire("plonk/#{self.id}", nb_days * 86400)
    logs.create(:description => "Interdiction de tribune pour #{pluralize nb_days, "jour"}", :user_id => user_id)
  end

  def can_plonk?
    moderator? || admin?
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
                         256 => :hide_signature,
                         :scopes => false
  attr_accessible :hide_avatar,
                  :news_on_home,
                  :diaries_on_home,
                  :posts_on_home,
                  :polls_on_home,
                  :wiki_pages_on_home,
                  :trackers_on_home,
                  :sort_by_date_on_home,
                  :hide_signature

  def types_on_home
    %w(News Diary Post Poll WikiPage Tracker).select do |type|
      send "#{type.tableize}_on_home?"
    end
  end

### Stylesheet ###

  before_validation :validate_css
  def validate_css
    return if stylesheet.blank?
    return if stylesheet.starts_with?("http://")
    return if stylesheet.starts_with?("https://")
    return if Stylesheet.include?(stylesheet)
    errors.add(:stylesheet, "Feuille de style non valide")
  end

  def stylesheet_url
    case
    when uploaded_stylesheet.present? then uploaded_stylesheet.url
    when stylesheet.present?          then stylesheet
    else 'application'
    end
  end
end
