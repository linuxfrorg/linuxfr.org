# encoding: UTF-8
# == Schema Information
#
# Table name: news
#
#  id           :integer          not null, primary key
#  state        :string(10)       default("draft"), not null
#  title        :string(160)      not null
#  cached_slug  :string(165)
#  moderator_id :integer
#  section_id   :integer
#  author_name  :string(32)       not null
#  author_email :string(64)       not null
#  body         :text
#  second_part  :text(2147483647)
#  created_at   :datetime
#  updated_at   :datetime
#

#
# The news are the first content in LinuxFr.org.
# Anonymous and authenticated users can submit a news
# that will be reviewed and moderated by the LinuxFr.org team.
#
class News < Content
  self.table_name = "news"
  self.type = "Dépêche"

  belongs_to :section
  belongs_to :moderator, :class_name => "User"
  has_many :links, :dependent => :destroy, :inverse_of => :news
  has_many :paragraphs, :dependent => :destroy, :inverse_of => :news
  accepts_nested_attributes_for :links, :allow_destroy => true
  accepts_nested_attributes_for :paragraphs, :allow_destroy => true
  has_many :versions, :class_name => 'NewsVersion',
                      :dependent  => :destroy,
                      :order      => 'version DESC',
                      :inverse_of => :news

  attr_accessible :title, :section_id, :author_name, :author_email, :links_attributes, :paragraphs_attributes

  scope :sorted,    order("created_at DESC")
  scope :draft,     where(:state => "draft")
  scope :candidate, where(:state => "candidate")
  scope :refused,   where(:state => "refused")
  scope :with_node_ordered_by, lambda {|order| joins(:node).where("nodes.public = 1").order("nodes.#{order} DESC") }

  validates :title,        :presence => { :message => "Le titre est obligatoire" },
                           :length   => { :maximum => 100, :message => "Le titre est trop long" }
  validates :body,         :presence => { :message => "Nous n'acceptons pas les dépêches vides" }
  validates :section,      :presence => { :message => "Veuillez choisir une section pour cette dépêche" }
  validates :author_name,  :presence => { :message => "Veuillez entrer votre nom" },
                           :length   => { :maximum => 32, :message => "Le nom de l'auteur est trop long" }
  validates :author_email, :presence => { :message => "Veuillez entrer votre adresse email" },
                           :length   => { :maximum => 64, :message => "L'adresse email de l'auteur est trop longue" }

### SEO ###

  extend FriendlyId
  friendly_id

### Search ####

  mapping do
    indexes :id,          :index    => :not_analyzed
    indexes :created_at,  :type => 'date', :include_in_all => false
    indexes :username,    :as => 'user.try(:name)',           :boost => 6,  :index => 'not_analyzed'
    indexes :section,     :as => 'section.title.tr ".", "-"', :boost => 12, :index => 'not_analyzed'
    indexes :title,       :analyzer => 'french',              :boost => 50
    indexes :body,        :analyzer => 'french',              :boost => 5
    indexes :second_part, :analyzer => 'french',              :boost => 3
  end

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
    event :rewrite do transition :candidate => :draft     end
    event :delete  do transition :published => :deleted   end

    after_transition :on => :accept, :do => :publish
    after_transition :on => :refuse, :do => :be_refused
    after_transition :on => :rewrite, :do => :be_rewritten
  end

  def submit_and_notify(user)
    submit!
    node.created_at = DateTime.now
    node.save
    Push.create(self, :kind => :submit, :username => user.name)
  end

  def publish
    node.make_visible
    author_account.try(:give_karma, 50)
    Push.create(self, :kind => :publish, :username => moderator.name)
    $redis.publish "news", {:id => self.id, :title => title, :slug => cached_slug}.to_json
  end

  def be_refused
    Push.create(self, :kind => :refuse, :username => moderator.name)
  end

  def be_rewritten
    reset_votes
    Push.create(self, :kind => :rewritten, :username => moderator.name)
  end

  def self.create_for_redaction(account)
    news = News.new
    news.title = "Nouvelle dépêche #{News.maximum(:id).to_i + 1}"
    news.section = Section.default
    news.wiki_body = news.wiki_second_part = "Vous pouvez éditer cette partie en cliquant sur le crayon !"
    news.cc_licensed = true
    news.author_name  = account.name
    news.author_email = account.email
    news.editor = account
    news.save
    news
  end

### Virtual attributes ###

  attr_accessor   :message, :wiki_body, :wiki_second_part, :editor, :pot_de_miel
  attr_accessible :message, :wiki_body, :wiki_second_part

  before_validation :mark_links_for_destruction
  def mark_links_for_destruction
    links.each do |link|
      link.mark_for_destruction if link.url.blank?
    end
  end

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
    self.body        = wikify(wiki_body).gsub(/^<p>NdM/, '<p><abbr title="Note des modérateurs">NdM</abbr>')
    self.second_part = wikify(wiki_second_part).gsub(/^<p>NdM/, '<p><abbr title="Note des modérateurs">NdM</abbr>')
  end

  sanitize_attr :body
  sanitize_attr :second_part

  after_create :create_parts
  def create_parts
    paragraphs.create(:second_part => false, :wiki_body => wiki_body)        unless wiki_body.blank?
    paragraphs.create(:second_part => true,  :wiki_body => wiki_second_part) unless wiki_second_part.blank?
  end

  def second_part_toc
    self.wiki_second_part ||= paragraphs.in_second_part.map(&:wiki_body).join("\n\n")
    toc_for wiki_second_part
  end

  def announce_toc
    Push.create(self, :kind => :second_part_toc, :toc => second_part_toc)
  end

  after_create :announce_message, :unless => Proc.new { |news| news.message.blank? }
  def announce_message
    Board.new(:object_type => Board.news, :object_id => self.id, :message => message, :user_name => author_name).save
  end

  after_update :announce_modification
  def announce_modification
    Push.create(self, :kind => :update, :title => title, :section => { :id => section.id, :title => section.title })
  end

### Versioning ###

  after_save :create_new_version, :if => Proc.new { |news| news.body_changed? || news.second_part_changed? || news.title_changed? }
  def create_new_version
    v = versions.create(:user_id    => (editor || author_account).try(:user_id),
                       :title       => title,
                       :body        => wiki_body,
                       :second_part => wiki_second_part,
                       :links       => links.map(&:to_s).join("\n"))
    Push.create(self, :kind => :revision, :id => v.id, :version => v.version, :message => v.message, :username => v.author_name)
  end

  def attendees
    User.joins(:news_versions).
         where("news_versions.news_id" => self.id).
         group("users.id").
         select("users.*")
  end

### Associated node ###

  def author_account
    Account.active.find_by_email(author_email)
  end

  def create_node(attrs={})
    self.tmp_owner_id = author_account.try(:user_id)
    attrs[:public] = false
    super attrs
  end

### Moderators' votes ###

  def vote_on_candidate(value, account)
    word = value > 0 ? "pour" : "contre"
    who  = account.login
    if value.abs == 2
      $redis.srem("news/#{self.id}/pour", who)
      $redis.srem("news/#{self.id}/contre", who)
    else
      $redis.incr("users/#{who}/nb_votes")
      key = "users/#{who}/nb_votes/#{Date.today.yday}"
      $redis.incr(key)
      $redis.expire(key, 2678400) # 31 days
    end
    $redis.sadd("news/#{self.id}/#{word}", who)
    Push.create(self, :news_id => self.id, :kind => :vote, :word => word, :username => who)
  end

  def voters_for
    $redis.smembers("news/#{self.id}/pour").to_sentence
  end

  def voters_against
    $redis.smembers("news/#{self.id}/contre").to_sentence
  end

  def reset_votes
    %w(pour contre).each {|word| $redis.del("news/#{self.id}/#{word}") }
    node.update_column(:score, 0)
  end

### ACL ###

  def self.accept_threshold
    Account.amr.count / 6
  end

  def self.refuse_threshold
    -Account.amr.count / 5
  end

  def viewable_by?(account)
    published? || (account && draft?) || account.try(:amr?)
  end

  def updatable_by?(account)
    published? ? account.amr? : viewable_by?(account)
  end

  def destroyable_by?(account)
    account.moderator? || account.admin?
  end

  def commentable_by?(account)
    super(account) && published?
  end

  def taggable_by?(account)
    super(account) || (account.amr? && candidate?)
  end

  def acceptable_by?(account)
    account.admin? || (account.moderator? && acceptable?)
  end

  def refusable_by?(account)
    account.admin? || (account.moderator? && refusable?)
  end

  def resetable_by?(account)
    account.admin?
  end

  def rewritable_by?(account)
    account.admin?
  end

  def pppable_by?(account)
    (account.moderator? || account.admin?) && published?
  end

  def votable_by?(account)
    super(account) || (account.amr? && candidate? && !submitted_by?(account))
  end

  def acceptable?
    score > News.accept_threshold
  end

  def refusable?
    score < News.refuse_threshold
  end

  def submitted_by?(account)
    node.user_id == account.user_id
  end

### Locks ###

  def lock_key
    "locks/#{self.id}/reorganize"
  end

  def lock_by(user)
    return false if links.any?      { |l| l.locked? && !l.locked_by?(user.id) }
    return false if paragraphs.any? { |p| p.locked? && !p.locked_by?(user.id) }
    locker_id = $redis.get(lock_key)
    return locker_id.to_i == user.id if locker_id
    $redis.set lock_key, user.id
    $redis.expire lock_key, 1800
    true
  end

  def unlock
    $redis.del lock_key
  end

  def locked_for_reorg?
    !!$redis.get(lock_key)
  end

  def unlocked?
    return false if $redis.get lock_key
    return false if links.any? { |l| l.locked? }
    return false if paragraphs.any? { |p| p.locked? }
    true
  end

  def locker
    locker_id = $redis.get lock_key
    User.find(locker_id).name if locker_id
  end

end
