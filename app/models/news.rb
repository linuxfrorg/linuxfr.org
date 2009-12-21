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
#  author_name  :string(255)     default("anonymous"), not null
#  author_email :string(255)     default("anonymous@dlfp.org"), not null
#  created_at   :datetime
#  updated_at   :datetime
#

# The news are the first content in LinuxFr.org.
# Anonymous and authenticated users can submit a news
# that will be reviewed and moderated by the LinuxFr.org team.
#
class News < Content
  include AASM

  belongs_to :section
  belongs_to :moderator, :class_name => "User"
  has_many :boards, :as => :object, :dependent => :destroy
  has_many :links, :dependent => :destroy
  has_many :paragraphs, :dependent => :destroy
  accepts_nested_attributes_for :links, :allow_destroy => true,
      :reject_if => proc { |attrs| attrs['title'].blank? && attrs['url'].blank? }
  accepts_nested_attributes_for :paragraphs, :allow_destroy => true,
      :reject_if => proc { |attrs| attrs['body'].blank? }

  attr_accessible :title, :section_id, :author_name, :author_email, :links_attributes, :paragraphs_attributes

  validates_presence_of :title,   :message => "Le titre est obligatoire"
  validates_presence_of :body,    :message => "Nous n'acceptons pas les dépêches vides"
  validates_presence_of :section, :message => "Veuillez choisir une section pour cette dépêche"

### Virtual attributes ###

  attr_accessor   :message, :wiki_body, :wiki_second_part, :editor_id
  attr_accessible :message, :wiki_body, :wiki_second_part

  before_validation :wikify_fields
  def wikify_fields
    self.body        = wikify wiki_body
    self.second_part = wikify wiki_second_part
  end

  after_create :create_parts
  def create_parts
    paragraphs.in_first_part.create(:wiki_body => wiki_body)         unless wiki_body.blank?
    paragraphs.in_second_part.create(:wiki_body => wiki_second_part) unless wiki_second_part.blank?
    return if message.blank?
    boards.indication.create(:message => message, :user_agent => author_name)
  end

  before_validation_on_update :put_paragraphs_together
  def put_paragraphs_together
    self.body        = wikify paragraphs.in_first_part.map(&:body).join
    self.second_part = wikify paragraphs.in_second_part.map(&:body).join
  end

  after_update :announce_modification
  def announce_modification
    message = render_to_string(:partial => 'news/board', :locals => {:action => 'dépêche modifiée :', :news => self})
    boards.edition.create(:message => message, :user_id => editor_id)
  end

### SEO ###

  has_friendly_id :title, :use_slug => true

### Sphinx ####

  define_index do
    indexes title, body, second_part
    indexes author_name, :as => :user
    indexes section.title, :as => :section, :facet => true
    where "news.state = 'published'"
    set_property :field_weights => { :title => 25, :user => 10, :body => 3, :second_part => 2, :section => 4 }
    set_property :delta => :datetime, :threshold => 75.minutes
  end

### Workflow ###

  aasm_column :state
  aasm_initial_state :draft

  aasm_state :draft
  aasm_state :candidate
  aasm_state :waiting
  aasm_state :published
  aasm_state :refused
  aasm_state :deleted

  aasm_event :submit  do transitions :from => [:draft],     :to => :candidate end
  aasm_event :wait    do transitions :from => [:candidate], :to => :waiting   end
  aasm_event :unblock do transitions :from => [:wait],      :to => :candidate end
  aasm_event :accept  do transitions :from => [:candidate], :to => :published, :on_transition => :publish    end
  aasm_event :refuse  do transitions :from => [:candidate], :to => :refused,   :on_transition => :be_refused end
  aasm_event :delete  do transitions :from => [:published], :to => :deleted,   :on_transition => :deletion   end

  def submit_and_notify(user_id)
    submit!
    boards.submission.create(:message => "<b>La dépêche a été soumise à la modération</b>", :user_id => user_id)
  end

  def publish
    node.update_attribute(:public, true)
    author = Account.find_by_email(author_email)
    author.give_karma(50) if author
    boards.moderation.create(:message => "<b>La dépêche a été publiée</b>", :user_id => moderator_id)
  end

  def be_refused
    boards.moderation.create(:message => "<b>La dépêche a été refusée</b>", :user_id => moderator_id)
  end

  def deletion
    boards.moderation.create(:message => "<b>La dépêche a été supprimée</b>", :user_id => moderator_id)
  end

  def self.accept_threshold
    User.amr.count / 5
  end

  def self.refuse_threshold
    -User.amr.count / 4
  end

  def announce_vote?
    candidate?
  end

### ACL ###

  def readable_by?(user)
    published? || (user && (user.amr? || (draft? && user.writer)))
  end

  def creatable_by?(user)
    true
  end

  def editable_by?(user)
    return false unless user
    published? ? (user.moderator? || user.admin?) : readable_by?(user)
  end

  def deletable_by?(user)
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
    return false if links.any{ |l| l.locked_by }
    return false if paragraphs.any{ |p| p.locked_by }
    true
  end

  def clear_locks(user)
    links.each {|l| l.locked_by = nil; l.save }
    paragraphs.each {|p| p.locked_by = nil; p.save }
    boards.lock.create(:message => "<span class=\"clear\">#{user.name} a supprimer tous les locks</span>", :user_id => user.id)
  end

### PPP ###

  def self.ppp
    id = Dictionary['PPP']
    id && find(id)
  end

  def set_on_ppp
    Dictionary['PPP'] = self.id
  end

  def on_ppp?
    self.id == Dictionary['PPP'].to_i
  end

### Interest ###

  def self.interest_coefficient
    5
  end

end
