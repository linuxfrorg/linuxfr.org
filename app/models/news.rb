# encoding: UTF-8
#
# == Schema Information
#
# Table name: news
#
#  id           :integer(4)      not null, primary key
#  state        :string(10)      default("draft"), not null
#  title        :string(160)     not null
#  cached_slug  :string(165)
#  moderator_id :integer(4)
#  section_id   :integer(4)
#  author_name  :string(32)      not null
#  author_email :string(64)      not null
#  body         :text
#  second_part  :text(16777215)
#  created_at   :datetime
#  updated_at   :datetime
#

# The news are the first content in LinuxFr.org.
# Anonymous and authenticated users can submit a news
# that will be reviewed and moderated by the LinuxFr.org team.
#
class News < Content
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

  validates :title,        :presence => { :message => "Le titre est obligatoire" },
                           :length   => { :maximum => 100, :message => "Le titre est trop long" }
  validates :body,         :presence => { :message => "Nous n'acceptons pas les dépêches vides" }
  validates :section,      :presence => { :message => "Veuillez choisir une section pour cette dépêche" }
  validates :author_name,  :presence => { :message => "Veuillez entrer votre nom" },
                           :length   => { :maximum => 32, :message => "Le nom de l'auteur est trop long" }
  validates :author_email, :presence => { :message => "Veuillez entrer votre adresse email" },
                           :length   => { :maximum => 64, :message => "L'adresse email de l'auteur est trop longue" }

### SEO ###

  has_friendly_id :title, :use_slug => true, :reserved_words => %w(index nouveau)

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

  # The workflow for news is not simple, and can traverse these states:
  #  - draft: the news is the redaction space and its writing is not finished
  #  - candidate: the news has been submitted and can be examined by reviewers
  #  - waiting: the news is in the moderation space, but the votes are blocked (aka 755)
  #  - published: the news is accepted and visible by any visitor
  #  - refused: the news is not good enough and has been refused by a moderator
  #  - deleted: the news is a spam or has been unpublished
  #
  state_machine :state, :initial => :draft do
    event :submit  do transition :draft     => :candidate end
    event :wait    do transition :candidate => :waiting   end
    event :unblock do transition :waiting   => :candidate end
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
    node.make_visible
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

  def self.create_for_redaction(account)
    news = News.new
    news.title = "Nouvelle dépêche #{News.maximum :id}"
    news.section = Section.published.first
    news.wiki_body = news.wiki_second_part = "Vous pouvez éditer cette partie en cliquant dessus !"
    news.author_name  = account.name
    news.author_email = account.email
    news.save
    news
  end

### Virtual attributes ###

  attr_accessor   :message, :wiki_body, :wiki_second_part, :editor, :pot_de_miel
  attr_accessible :message, :wiki_body, :wiki_second_part

  # The body of a news (first and second parts) is duplicated:
  # one copy is in the news object itself, the other is shared by several paragraphs.
  #
  # Until its recording in database, a news has no paragraphs, so body and
  # second_part are the references. At its creation, these fields are split in
  # paragraphs, and the paragraphs become the main field. The news lives, its
  # paragraphs are edited in the redaction space first, and in the moderation
  # space after. When the news is published (if it's accepted), the paragraphs
  # are merged into the body and second_part. These two fields are used to show
  # the news.
  #
  # In fact, it's more complicated as we have both wiki source and generated html
  # on body, second_part and the paragraphs.

  before_validation :put_paragraphs_together, :on => :update
  def put_paragraphs_together
    self.wiki_body        = paragraphs.in_first_part.map(&:wiki_body).join("\n\n")
    self.wiki_second_part = paragraphs.in_second_part.map(&:wiki_body).join("\n\n")
  end

  before_validation :wikify_fields
  def wikify_fields
    return if wiki_body.blank?
    self.body        = wikify(wiki_body).gsub(/^<p>NdM :/, '<p><abbr title="Note des modérateurs">NdM</abbr> :')
    self.second_part = wikify(wiki_second_part)
  end

  sanitize_attr :body
  sanitize_attr :second_part

  after_create :create_parts
  def create_parts
    paragraphs.create(:second_part => false, :wiki_body => wiki_body)        unless wiki_body.blank?
    paragraphs.create(:second_part => true,  :wiki_body => wiki_second_part) unless wiki_second_part.blank?
    return if message.blank?
    Board.create_for(self, :user => author_name, :kind => "indication", :message => message)
  end

  after_update :announce_modification
  def announce_modification
    return unless editor
    message = NewsController.new.render_to_string(:partial => 'board', :locals => {:action => 'dépêche modifiée :', :news => self})
    Board.create_for(self, :user => editor, :kind => "edition", :message => message)
  end

### Associated node ###

  def create_node(attrs={}, replace_existing=true)
    account = Account.find_by_email(author_email)
    self.owner_id = account.try(:user_id)
    attrs[:public] = false
    super attrs, replace_existing
  end

### ACL ###

  def self.accept_threshold
    Account.amr.count / 6
  end

  def self.refuse_threshold
    -Account.amr.count / 5
  end

  def viewable_by?(account)
    published? || (account && draft? && account.writer?) || account.try(:amr?)
  end

  def creatable_by?(account)
    true
  end

  def updatable_by?(account)
    return false unless account
    published? ? (account.moderator? || account.admin?) : viewable_by?(account)
  end

  def destroyable_by?(account)
    account && (account.moderator? || account.admin?)
  end

  def acceptable_by?(account)
    account && (account.admin? || (account.moderator? && acceptable?))
  end

  def refusable_by?(account)
    account && (account.admin? || (account.moderator? && refusable?))
  end

  def pppable_by?(account)
    account && (account.moderator? || account.admin?) && published?
  end

  def votable_by?(account)
    super(account) || (account && account.amr? && candidate? && self.node.user_id != account.user_id)
  end

  def acceptable?
    score > News.accept_threshold
  end

  def refusable?
    score < News.refuse_threshold
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
    message = "<span class=\"clear\">#{user.name} a supprimé tous les locks</span>"
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

end
