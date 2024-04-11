# encoding: UTF-8
# == Schema Information
#
# Table name: news
#
#  id           :integer          not null, primary key
#  state        :string(10)       default("draft"), not null
#  title        :string(160)      not null
#  cached_slug  :string(165)      not null
#  moderator_id :integer
#  section_id   :integer          not null
#  author_name  :string(32)       not null
#  author_email :string(64)       not null
#  body         :text(4294967295)
#  second_part  :text(4294967295)
#  created_at   :datetime
#  updated_at   :datetime
#  submitted_at :datetime
#

#
# The news are the first content in LinuxFr.org.
# Anonymous and authenticated users can submit a news
# that will be reviewed and moderated by the LinuxFr.org team.
#
class News < Content
  DEFAULT_FIRST_PART = "Un **court chapeau** introduisant l’article, ou le " +
    "synthétisant, aidera les lecteurs à savoir s’ils doivent lire la suite " +
    "de votre article. Nous vous recommandons d'ajouter une illustration. " +
    "(Vous pouvez éditer ce paragraphe en cliquant sur le crayon !)".freeze
  DEFAULT_SECOND_PART = "Votre article commence ici. Un sommaire sera automatiquement " +
    "créé si nécessaire. Pensez à l'orthographe et aux liens explicatifs vers Wikipedia. " +
    "(Vous pouvez éditer ce paragraphe en cliquant sur le crayon !)".freeze
  DEFAULT_PARAGRAPH = "Vous pouvez éditer ce paragraphe en cliquant sur le crayon !".freeze
  LINUXFR_BOT = "Le bot LinuxFr".freeze
  MODERATION_TEAM = "L'équipe de modération".freeze

  self.table_name = "news"
  self.type = "Dépêche"

  belongs_to :section
  belongs_to :moderator, class_name: "User"
  has_many :links, dependent: :destroy, inverse_of: :news
  has_many :paragraphs, dependent: :destroy, inverse_of: :news
  accepts_nested_attributes_for :links, allow_destroy: true, reject_if: proc { |attrs| attrs['url'].blank? }
  accepts_nested_attributes_for :paragraphs, allow_destroy: true
  has_many :versions,
    -> { order(version: :desc) },
    class_name: "NewsVersion",
    dependent: :destroy,
    inverse_of: :news

  validates_associated :section, message: "Veuillez choisir une section pour cette dépêche"

  scope :sorted,    -> { order(updated_at: :desc) }
  scope :draft,     -> { where(state: "draft").includes(node: :user) }
  scope :candidate, -> { where(state: "candidate") }
  scope :refused,   -> { where(state: "refused") }
  scope :with_node_ordered_by, ->(order) { joins(:node).where("nodes.public = 1").order("nodes.#{order} DESC") }

  validates :title,        presence: { message: "Le titre est obligatoire" },
                           length: { maximum: 100, message: "Le titre est trop long" }
  validates :body,         presence: { message: "Nous n’acceptons pas les dépêches vides" }
  validates :section,      presence: { message: "Veuillez choisir une section pour cette dépêche" }
  validates :author_name,  presence: { message: "Veuillez entrer votre nom" },
                           length: { maximum: 32, message: "Le nom de l’auteur est trop long" }
  validates :author_email, presence: { message: "Veuillez entrer votre adresse de courriel" },
                           length: { maximum: 64, message: "L’adresse de courriel de l’auteur est trop longue" }

### SEO ###

  extend FriendlyId
  friendly_id

  def should_generate_new_friendly_id?
    title_changed?
  end

### Workflow ###

  # The workflow for news is not simple, and can traverse these states:
  #  - draft: the news is the redaction space and its writing is not finished
  #  - candidate: the news has been submitted and can be examined by moderators
  #  - published: the news is accepted and visible by any visitor
  #  - refused: the news is not good enough and has been refused by a moderator
  #  - deleted: the news is a spam or has been unpublished
  #
  # news.created_at:   when the news was started
  # news.updated_at:   when the news was edited for the last time (can also be when the news is refused/deleted)
  # news.submitted_at: when the news was submitted to the moderation
  # nodes.created_at:  when the news was published (or pushed in moderation if not yet moderated)
  # nodes.updated_at:  when the news was last commented at (among other things)
  #
  state_machine :state, initial: :draft do
    event :submit  do transition :draft     => :candidate end
    event :accept  do transition :candidate => :published end
    event :refuse  do transition :candidate => :refused   end
    event :rewrite do transition :candidate => :draft     end
    event :delete  do transition :published => :deleted   end
    event :erase   do transition :draft     => :deleted   end

    after_transition on: :accept,  do: :publish
    after_transition on: :refuse,  do: :be_refused
    after_transition on: :rewrite, do: :be_rewritten
  end

  before_create :reset_submitted_at
  def reset_submitted_at
    self.submitted_at = 1.year.from_now
  end

  def submit_and_notify(user)
    self.submitted_at = DateTime.now
    submit!
    node.created_at = DateTime.now
    node.save
    message = "<b>La dépêche a été soumise à la modération.</b>"
    Board.new(object_type: Board.news, object_id: self.id, message: message, user_name: user.name).save
    Push.create(self, kind: :submit, username: user.name)
  end

  def publish
    node.make_visible
    author_account.try(:give_karma, 50)
    message = "<b>La dépêche a été publiée.</b>"
    Board.new(object_type: Board.news, object_id: self.id, message: message, user_name: MODERATION_TEAM).save
    Push.create(self, kind: :publish, username: moderator.name)
    $redis.publish "news", { id: self.id, title: title, slug: cached_slug }.to_json
    diary_id = $redis.get("convert/#{self.id}")
    Diary.find(diary_id).update_column(:converted_news_id, self.id) if diary_id
  end

  def be_refused
    message = "<b>La dépêche a été refusée.</b>"
    Board.new(object_type: Board.news, object_id: self.id, message: message, user_name: MODERATION_TEAM).save
    Push.create(self, kind: :refuse, username: moderator.name)
  end

  def be_rewritten
    reset_votes
    message = "<b>La dépêche a été retournée en rédaction.</b>"
    Board.new(object_type: Board.news, object_id: self.id, message: message, user_name: MODERATION_TEAM).save
    Push.create(self, kind: :rewritten, username: moderator.name)
  end

  def self.create_for_redaction(account)
    news = News.new
    news.title = "Nouvelle dépêche nᵒ #{News.maximum(:id).to_i + 1}"
    news.section = Section.default
    news.wiki_body = DEFAULT_FIRST_PART
    news.wiki_second_part = DEFAULT_SECOND_PART
    news.cc_licensed = true
    news.author_name  = account.name
    news.author_email = account.email
    news.editor = account
    news.save
    message = "Merci d’avoir initié cette rédaction coopérative !
      Durant toute la phase de rédaction, vous pourrez utiliser la présente
      messagerie instantanée pour discuter avec les participants."
    Board.new(object_type: Board.news, object_id: news.id, message: message, user_name: LINUXFR_BOT).save
    news
  end

  def followup(message, user)
    NewsNotifications.followup(self, message).deliver_now
    msg = "<b>Relance :</b> #{message}"
    Board.new(object_type: Board.news, object_id: self.id, message: msg, user_name: user.name).save
  end

### Virtual attributes ###

  attr_accessor   :message, :wiki_body, :wiki_second_part, :urgent, :editor, :pot_de_miel

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

  before_validation :put_paragraphs_together, on: :update
  def put_paragraphs_together
    self.wiki_body        = paragraphs.in_first_part.map(&:wiki_body).join("\n\n")
    self.wiki_second_part = paragraphs.in_second_part.map(&:wiki_body).join("\n\n")
  end

  before_validation :wikify_fields
  def wikify_fields
    return if wiki_body.blank?
    self.body        = wikify(wiki_body).gsub(/^<p>N\.?\p{Z}?[Dd]\.?\p{Z}?M\.?\p{Z}?:/, '<p><abbr title="Note de la modération">N. D. M. :</abbr>')
    self.second_part = wikify(wiki_second_part).gsub(/^<p>N\.?\p{Z}?[Dd]\.?\p{Z}?M\.?\p{Z}?:/, '<p><abbr title="Note de la modération">N. D. M. :</abbr>')
  end

  mark_as_safe_attr :body
  mark_as_safe_attr :second_part

  after_create :create_parts
  def create_parts
    paragraphs.create(second_part: false, wiki_body: wiki_body)        unless wiki_body.blank?
    paragraphs.create(second_part: true,  wiki_body: wiki_second_part) unless wiki_second_part.blank?
  end

  def second_part_toc
    toc_for second_part
  end

  after_update :announce_toc
  def announce_toc
    return if second_part.blank?
    Push.create(self, kind: :second_part_toc, toc: second_part_toc)
  end

  after_create :announce_message, unless: Proc.new { |news| news.message.blank? }
  def announce_message
    Board.new(object_type: Board.news, object_id: self.id, message: message, user_name: author_name).save
  end

  after_update :announce_modification
  def announce_modification
    Push.create(self, kind: :update, title: title, section: { id: section.id, title: section.title })
  end

  def has_default_paragraph?
    paragraphs.any? { |p| p.wiki_body == DEFAULT_PARAGRAPH }
  end

### Versioning ###

  after_save :create_new_version, if: Proc.new { |n| n.saved_change_to_body? || n.saved_change_to_second_part? || n.saved_change_to_title? || n.saved_change_to_section_id? }
  def create_new_version
    v = versions.create(user_id: (editor || author_account || Account.anonymous).try(:user_id),
                        title: "#{section.title} : #{title}",
                        body: wiki_body,
                        second_part: wiki_second_part,
                        links: links.map(&:to_s).join("\n"))
    Push.create(self, kind: :revision, id: v.id, version: v.version, message: v.message, username: v.author_name, creationdate: I18n.l(v.created_at, :format => '%d %B %Y %H:%M:%S'))
  end

  def attendees
    User.joins(:news_versions).
         where("news_versions.news_id" => self.id).
         group("users.id").
         select("users.*, COUNT(news_versions.id) AS nb_editions").
         order("nb_editions DESC")
  end

  def edited_by
    attendees.where("users.id != ?", node.user_id || 1)
  end

  def nb_editors
    @nb ||= NewsVersion.where(news_id: self.id).
                        group("user_id").
                        pluck("1").
                        length - 1
  end

  def reorganize(params)
    reorganized = false
    self.transaction do
      Paragraph.where(news_id: self.id).delete_all
      self.attributes = params
      create_parts
      # Let commit transaction only if save is successful so version will be well created
      if save
        reorganized = true
      else
        raise ActiveRecord::Rollback
      end
    end
    unlock if reorganized
    reorganized
  end

### Associated node ###

  def author_account
    Account.active.find_by(email: author_email)
  end

  def create_node(attrs={})
    self.tmp_owner_id = author_account.try(:user_id)
    attrs[:public] = false
    super attrs
  end

  def reassign_to(user_id, editor_name)
    user = User.find(user_id)
    return unless user
    node.update_column(:user_id, user.id)
    self.author_name  = user.name
    self.author_email = user.account.try(:email) || 'collectif@linuxfr.org'
    message = "La paternité de la dépêche revient maintenant à #{user.name}"
    Board.new(object_type: Board.news, object_id: self.id, message: message, user_name: editor_name).save
    Push.create(self, kind: :chat, username: editor_name)
    save
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
    Push.create(self, news_id: self.id, kind: :vote, word: word, username: who)
  end

  def voters_for
    $redis.smembers("news/#{self.id}/pour").to_sentence
  end

  def voters_against
    $redis.smembers("news/#{self.id}/contre").to_sentence
  end

  def nb_voters_for
    $redis.scard("news/#{self.id}/pour")
  end

  def nb_voters_against
    $redis.scard("news/#{self.id}/contre")
  end

  def reset_votes
    %w(pour contre).each {|word| $redis.del("news/#{self.id}/#{word}") }
    $redis.keys("nodes/#{node.id}/votes/*").each {|key| $redis.del key }
    node.update_column(:score, 0)
  end

### Urgent flag ###

  def urgent?
    $redis.sismember("news/urgent", self.id)
  end

  def urgent!
    $redis.sadd("news/urgent", self.id)
  end

  def no_more_urgent!
    $redis.srem("news/urgent", self.id)
  end

### ACL ###

  def self.accept_threshold
    Account.amr.count / 7
  end

  def self.refuse_threshold
    -Account.amr.count / 6
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
    super(account) || account.amr? || account.editor? || (draft? && submitted_by?(account))
  end

  def acceptable_by?(account)
    account.admin? || (account.moderator? && acceptable?)
  end

  def refusable_by?(account)
    account.admin? || (account.moderator? && refusable?)
  end

  def rewritable_by?(account)
    refusable_by? account
  end

  def followupable_by?(account)
    draft? && (account.editor? || account.admin?)
  end

  def erasable_by?(account)
    account.editor? || account.amr? || only_edited_by?(account)
  end

  def reassignable_by?(account)
    account.editor? || account.amr?
  end

  def resetable_by?(account)
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

  def only_edited_by?(account)
    submitted_by?(account) && versions.where('user_id != ?', account.user_id).none?
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
