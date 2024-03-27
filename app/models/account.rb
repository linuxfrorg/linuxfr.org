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
#  email                  :string(128)      not null
#  encrypted_password     :string(128)      default(""), not null
#  confirmation_token     :string(64)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  reset_password_token   :string(64)
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
#  uploaded_stylesheet    :string(255)
#  last_seen_on           :date
#

#
# The accounts are the private informations about users.
# A user wth an account can login, change its password
# and do many other things on the site.
#
# There are several levels of users:
#   * anonymous     -> they have no account and can only read public contents
#   * authenticated -> they can read public contents and submit new ones
#   * maintainer    -> they can manage the tracker system
#   * moderator     -> they make the order and the security ruling
#   * editor        -> they edit the news in the redaction space
#   * admin         -> the almighty users
#
class Account < ApplicationRecord
  include Canable::Cans
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper

  has_many :applications, class_name: 'Doorkeeper::Application', as: :owner
  has_many :logs, dependent: :destroy
  belongs_to :user, inverse_of: :account, dependent: :delete, optional: true
  accepts_nested_attributes_for :user, reject_if: :all_blank

  mount_uploader :uploaded_stylesheet, StylesheetUploader

  attr_accessor :amr_id
  delegate :name, to: :user

  attr_accessor :totoz_style
  attr_accessor :totoz_source

  scope :unconfirmed, -> { where(confirmed_at: nil) }

### Validation ###

  LOGIN_REGEXP = /\A[\p{Word}.+\-]+\z/
  validates :login, presence: { message: "Veuillez choisir un pseudo"},
                    uniqueness: { message: "Ce pseudo est déjà pris" },
                    format: { message: "Le pseudo n’est pas valide", with: LOGIN_REGEXP, allow_blank: true, on: :create },
                    length: { maximum: 40, message: "Le nom du compte est trop long" }

  EMAIL_REGEXP = /\A[\p{Word}.%+\-]+@[\p{Word}.\-]+\.[\w]{2,}\z/i
  validates :email, presence: { message: "Veuillez remplir l’adresse de courriel" },
                    uniqueness: { message: "Cette adresse de courriel est déjà utilisée", case_sensitive: false, allow_blank: true },
                    format: { message: "L’adresse de courriel n’est pas valide", with: EMAIL_REGEXP, allow_blank: true },
                    length: { maximum: 128, message: "L’adresse de courriel est trop longue" }

  validates :password, presence: { message: "Le mot de passe est absent", on: :create },
                       confirmation: { message: "La confirmation du mot de passe ne correspond pas au mot de passe" }

  validates :stylesheet, length: { maximum: 255, message: "L’adresse de la feuille de style est trop longue" }

### Authentication ###

  devise :registerable, :database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable

  before_create :create_user
  def create_user
    self.user_id = User.create!(name: login).id
  end

  def self.anonymous
    where(login: "Anonyme").first
  end

### Password ###

  before_validation :generate_a_password, on: :create
  def generate_a_password
    chars = [*'A'..'Z'] + [*'a'..'z'] + [*'1'..'9'] + %w(- + ! ? : $ % &)
    pass  = chars.sample(8).join
    self.password = self.password_confirmation = pass
  end

  def update_with_password(params={}, *options)
    current_password = params.delete(:current_password)

    if params[:password].blank?
      return update(params.except :password, :password_confirmation)
    end

    result = if valid_password?(current_password)
      update(params, *options)
      logs.create(description: "Mot de passe modifié")
    else
      self.assign_attributes(params, *options)
      self.valid?
      self.errors.add(:current_password, "Mot de passe invalide")
      false
    end

    clean_up_passwords
    result
  end

### Role ###

  scope :active,    -> { where("role != 'inactive'") }
  scope :maintainer, -> { where(role: "maintainer") }
  scope :tracker_admin, -> { where(role: %w[admin maintainer]) }
  scope :moderator, -> { where(role: "moderator") }
  scope :editor,    -> { where(role: "editor") }
  scope :admin,     -> { where(role: "admin") }
  scope :amr,       -> { where(role: %w[admin moderator]) }

  state_machine :role, initial: :visitor do
    event :inactivate            do transition all             => :inactive  end
    event :reactivate            do transition :inactive       => :visitor   end
    event :remove_all_rights     do transition all - :inactive => :visitor   end
    event :give_maintainer_rights do transition all - :inactive => :maintainer end
    event :give_moderator_rights do transition all - :inactive => :moderator end
    event :give_editor_rights    do transition all - :inactive => :editor    end
    event :give_admin_rights     do transition all - :inactive => :admin     end
    after_transition do: :log_role
  end

  def display_role(hasContents)
    case role
    when 'visitor' then hasContents ? 'contributeur' : 'visiteur'
    when 'maintainer' then 'mainteneur'
    when 'editor' then 'animateur'
    when 'moderator' then 'modérateur'
    when 'admin' then 'admin'
    else 'compte fermé'
    end
  end

  def log_role
    roles = previous_changes["role"]
    return if roles.nil?
    logs.create(description: "Changement de rôle : #{roles.join ' → '}", user_id: amr_id)
  end

  # A tracker admin can update, assign and delete a node of the tracker
  def tracker_admin?
    admin? || maintainer?
  end

  # An AMR is someone who is either an admin or a moderator
  def amr?
    admin? || moderator?
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

  def display_last_seen_on
    if not last_seen_on
      'jamais'
    elsif last_seen_on >= 30.days.ago
      'dans les 30 derniers jours'
    elsif last_seen_on >= 1.year.ago
      'il y a moins d’un an'
    elsif last_seen_on >= 3.year.ago
      'il y a moins de trois ans'
    else
      'il y a plus de trois ans'
    end
  end

### Actions ###

  def viewable_by?(account)
    account && (account.admin? || account.moderator? || account.id == self.id)
  end

  def is?(account)
    account && account.id == self.id
  end

  def can_post_on_board?
    active_for_authentication? && !plonked? && karma > 0
  end

  def tag(node, tags)
    node.set_taglist(tags, user_id) unless tags.blank?
  end

  def read(node)
    node.read_by(self.id)
    $redis.srem? "dashboard/#{self.id}", node.id
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

### API ###

  def as_json(opts={})
    super opts.merge(only: [:login, :email, :created_at])
  end

  def authorized_applications
    Doorkeeper::Application.authorized_for self
  end

### Karma ###

  def self.default_karma
    column_defaults['karma']
  end

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
    logs.create(description: "#{who.login} a donné #{points} points de karma")
  end

### Blocked for comments ###

  def blocked?
    $redis.exists?("block/#{self.id}")
  end

  def block(nb_days, user_id)
    $redis.set("block/#{self.id}", 1)
    $redis.expire("block/#{self.id}", nb_days * 86400)
    if nb_days > 0
      logs.create(description: "Interdiction de poster des commentaires pendant #{pluralize nb_days, "jour"}", user_id: user_id)
    else
      logs.create(description: "Réautorisation de poster des commentaires", user_id: user_id)
    end
  end

  def can_block?
    moderator? || admin?
  end

### Plonk for the board ###

  def plonked?
    $redis.exists?("plonk/#{self.id}")
  end

  def plonk(nb_days, user_id)
    $redis.set("plonk/#{self.id}", 1)
    $redis.expire("plonk/#{self.id}", nb_days * 86400)
    if nb_days > 0
      logs.create(description: "Interdiction de tribune pendant #{pluralize nb_days, "jour"}", user_id: user_id)
    else
      logs.create(description: "Réautorisation de poster des commentaires", user_id: user_id)
    end
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
                         512 => :show_negative_nodes,
                        1024 => :bookmarks_on_home,
                        2048 => :board_in_sidebar,
                         scopes: false

  def types_on_home
    %w(News Diary Post Poll WikiPage Tracker Bookmark).select do |type|
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
