# == Schema Information
#
# Table name: news
#
#  id           :integer(4)      not null, primary key
#  state        :string(255)     default("draft"), not null
#  title        :string(255)
#  cache_slug   :string(255)
#  body         :text
#  second_part  :text
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
  has_many :boards, :as => :object, :dependent => :destroy
  has_many :links
  accepts_nested_attributes_for :links, :allow_destroy => true,
      :reject_if => proc { |attrs| attrs['title'].blank? && attrs['url'].blank? }

  attr_accessible :title, :body, :second_part, :section_id, :author_name, :author_email, :links_attributes, :message

  validates_presence_of :title,   :message => "Le titre est obligatoire"
  validates_presence_of :body,    :message => "Nous n'acceptons pas les dépêches vides"
  validates_presence_of :section, :message => "Veuillez choisir une section pour cette dépêche"

  wikify :body,        :as => :wikified_body
  wikify :second_part, :as => :wikified_second_part

### Message to the moderation team ###

  attr_accessor :message

  after_create :post_message
  def post_message
    return if message.blank?
    boards.create(:login => author_name, :message => message, :user_agent => 'auto')
  end

### SEO ###

  has_friendly_id :title

### Sphinx ####

  define_index do
    indexes title, body, second_part
    indexes author_name, :as => :user
    indexes section.title, :as => :section, :facet => true
    where "news.state = 'published'"
    set_property :field_weights => { :title => 25, :user => 10, :body => 3, :second_part => 2, :section => 4 }
    set_property :delta => :datetime, :threshold => 1.hour
  end

### Workflow ###

  aasm_column :state
  aasm_initial_state :draft

  aasm_state :draft
  aasm_state :published
  aasm_state :refused
  aasm_state :deleted

  aasm_event :accept do transitions :from => [:draft],   :to => :published, :on_transition => :publish end
  aasm_event :refuse do transitions :from => [:draft],     :to => :refused end
  aasm_event :delete do transitions :from => [:published], :to => :deleted end

  def publish
    node.update_attribute(:public, true)
  end

  def self.accept_threshold
    User.amr.count / 5
  end

  def self.refuse_threshold
    -User.amr.count / 4
  end

### Versioning ###

  attr_accessor :commit_message
  attr_accessor :committer

  versioning(:title, :body, :second_part) do |v|
    v.repository = Rails.root.join('git_store', 'news.git')
    v.message    = lambda { |news| news.commit_message }
    v.committer  = lambda { |news| [news.author_name, news.author_email] }
  end

### ACL ###

  def readable_by?(user)
    published? || (user && user.amr?)
  end

  def creatable_by?(user)
    true
  end

  def editable_by?(user)
    user && user.amr?
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
