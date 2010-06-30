# == Schema Information
#
# Table name: news
#
#  id           :integer(4)      not null, primary key
#  state        :string(255)     default("draft"), not null
#  title        :string(255)
#  cached_slug  :string(255)
#  body         :text
#  second_part  :text
#  moderator_id :integer(4)
#  section_id   :integer(4)
#  author_name  :string(255)     not null
#  author_email :string(255)     not null
#  created_at   :datetime
#  updated_at   :datetime
#

# The news are the first content in LinuxFr.org.
# Anonymous and authenticated users can submit a news
# that will be reviewed and moderated by the LinuxFr.org team.
#
class News < Content
  include Canable::Ables

  belongs_to :section
  belongs_to :moderator, :class_name => "User"
  has_many :links, :dependent => :destroy, :inverse_of => :news
  has_many :paragraphs, :dependent => :destroy, :inverse_of => :news
  accepts_nested_attributes_for :links, :allow_destroy => true,
      :reject_if => proc { |attrs| attrs['title'].blank? && attrs['url'].blank? }
  accepts_nested_attributes_for :paragraphs, :allow_destroy => true,
      :reject_if => proc { |attrs| attrs['body'].blank? }

  attr_accessible :title, :section_id, :author_name, :author_email, :links_attributes, :paragraphs_attributes

  scope :sorted,    order("created_at DESC")
  scope :draft,     where(:state => "draft")
  scope :candidate, where(:state => "candidate")

  validates :title,        :presence => { :message => "Le titre est obligatoire" }
  validates :body,         :presence => { :message => "Nous n'acceptons pas les dépêches vides" }
  validates :section,      :presence => { :message => "Veuillez choisir une section pour cette dépêche" }
  validates :author_name,  :presence => { :message => "Veuillez entrer votre nom" }
  validates :author_email, :presence => { :message => "Veuillez entrer votre adresse email" }

### Associated node ###

  after_create :create_associated_node
  def create_associated_node
    account = Account.find_by_email(author_email)
    create_node(:public => false, :user_id => (account && account.user_id))
  end

### Virtual attributes ###

  attr_accessor   :message, :wiki_body, :wiki_second_part, :editor
  attr_accessible :message, :wiki_body, :wiki_second_part

  before_validation :wikify_fields
  def wikify_fields
    return if wiki_body.blank?
    self.body        = wikify(wiki_body).gsub(/^NdM :/, '<abbr title="Note des modérateurs">NdM</abbr>')
    self.second_part = wikify(wiki_second_part)
  end

  after_create :create_parts
  def create_parts
    paragraphs.in_first_part.create(:wiki_body => wiki_body)         unless wiki_body.blank?
    paragraphs.in_second_part.create(:wiki_body => wiki_second_part) unless wiki_second_part.blank?
    return if message.blank?
    Board.create_for(news, :user => author_name, :kind => "indication", :message => message)
  end

# FIXME
#   before_validation :put_paragraphs_together, :on => :create
#   def put_paragraphs_together
#     self.body        = wikify paragraphs.in_first_part.map(&:body).join
#     self.second_part = wikify paragraphs.in_second_part.map(&:body).join
#   end

  after_update :announce_modification
  def announce_modification
    return unless editor
    message = NewsController.new.render_to_string(:partial => 'board', :locals => {:action => 'dépêche modifiée :', :news => self})
    Board.create_for(self, :user => editor, :kind => "edition", :message => message)
  end

### SEO ###

  has_friendly_id :title, :use_slug => true

### Sphinx ####

# TODO Thinking Sphinx
#   define_index do
#     indexes title, body, second_part
#     indexes author_name, :as => :user
#     indexes section.title, :as => :section, :facet => true
#     where "news.state = 'published'"
#     set_property :field_weights => { :title => 25, :user => 10, :body => 3, :second_part => 2, :section => 4 }
#     set_property :delta => :datetime, :threshold => 75.minutes
#   end

### Workflow ###

  state_machine :state, :initial => :draft do
    event :submit  do transition :draft     => :candidate end
    event :wait    do transition :candidate => :waiting   end
    event :unblock do transition :wait      => :candidate end
    event :accept  do transition :candidate => :published end
    event :refuse  do transition :candidate => :refused   end
    event :delete  do transition :published => :deleted   end

    after_transition :on => :accept, :do => :publish
    after_transition :on => :refuse, :do => :be_refused
    after_transition :on => :delete, :do => :deletion
  end

  def submit_and_notify(user)
    submit!
    message = "<b>La dépêche a été soumise à la modération</b>"
    Board.create_for(self, :user => user, :kind => "submission", :message => message)
  end

  def publish
    node.public = true
    node.created_at = DateTime.now
    node.save
    author = Account.find_by_email(author_email)
    author.give_karma(50) if author
    message = "<b>La dépêche a été publiée</b>"
    Board.create_for(self, :user => moderator, :kind => "moderation", :message => message)
  end

  def be_refused
    message = "<b>La dépêche a été refusée</b>"
    Board.create_for(self, :user => moderator, :kind => "moderation", :message => message)
  end

  def deletion
    message = "<b>La dépêche a été supprimée</b>"
    Board.create_for(self, :user => moderator, :kind => "moderation", :message => message)
  end

  def self.accept_threshold
    User.amr.count / 5
  end

  def self.refuse_threshold
    -User.amr.count / 4
  end

  def self.create_for_redaction(user)
    news = News.new
    news.title = "Nouvelle dépêche #{News.maximum :id}"
    news.section = Section.published.first
    news.wiki_body = news.wiki_second_part = "Vous pouvez éditer cette partie en cliquant dessus !"
    news.author_name  = user.name
    news.author_email = user.email
    news.save
    news
  end

### ACL ###

  def viewable_by?(user)
    published? || (user && (user.amr? || (draft? && user.writer)))
  end

  def creatable_by?(user)
    true
  end

  def updatable_by?(user)
    return false unless user
    published? ? (user.moderator? || user.admin?) : viewable_by?(user)
  end

  def destroyable_by?(user)
    user && (user.moderator? || user.admin?)
  end

  def acceptable_by?(user)
    user && (user.moderator? || user.admin?) && score > News.accept_threshold
  end

  def refusable_by?(user)
    user && (user.moderator? || user.admin?) && score < News.refuse_threshold
  end

  def pppable_by?(user)
    user && (user.moderator? || user.admin?) && published?
  end

  def votable_by?(user)
    super(user) || (user && user.amr? && !draft?)
  end

### Locks ###

  def unlocked?
    return false if links.any? { |l| l.locked? }
    return false if paragraphs.any? { |p| p.locked? }
    true
  end

  def clear_locks(user)
    links.each {|l| l.locked_by_id = nil; l.save }
    paragraphs.each {|p| p.locked_by_id = nil; p.save }
    message = "<span class=\"clear\">#{user.name} a supprimer tous les locks</span>"
    Board.create_for(self, :user => user, :kind => "locking", :message => message)
  end

### PPP ###

  def self.ppp
    id = $redis.get("news/ppp")
    id && find(id)
  end

  def set_on_ppp
    $redis.set("news/ppp", self.id)
  end

  def on_ppp?
    self.id == $redis.get("news/ppp").to_i
  end

### Interest ###

  def self.interest_coefficient
    5
  end

end
