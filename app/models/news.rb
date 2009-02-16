# == Schema Information
# Schema version: 20090120005239
#
# Table name: news
#
#  id          :integer(4)      not null, primary key
#  state       :string(255)     default("draft"), not null
#  title       :string(255)
#  body        :text
#  second_part :text
#  section_id  :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

# The news are the first content in LinuxFr.org.
# Anonymous and authenticated users can submit a news
# that will be reviewed and moderated by the LinuxFr.org team.
#
class News < Content
  include AASM

  belongs_to :section
  has_many :links
  accepts_nested_attributes_for :links, :allow_destroy => true,
      :reject_if => proc { |attrs| attrs[:title].blank? && attrs[:url].blank? }

  validates_presence_of :title,   :message => "Le titre est obligatoire"
  validates_presence_of :body,    :message => "Nous n'acceptons pas les dépêches vides"
  validates_presence_of :section, :message => "Veuillez choisir une section pour cette dépêche"

### Workflow ###

  aasm_column :state
  aasm_initial_state :draft

  aasm_state :draft
  aasm_state :published
  aasm_state :refused
  aasm_state :deleted

  aasm_event :accept do transitions :from => [:draft],   :to => :published end
  aasm_event :refuse do transitions :from => [:draft],     :to => :refused end
  aasm_event :delete do transitions :from => [:published], :to => :deleted end

  def self.accept_threshold
    User.count_amr / 5
  end

  def self.refuse_threshold
    -User.count_amr / 4
  end

### Body ###

  attr_accessor :commit_message
  attr_accessor :committer

  versioning(:title, :body, :second_part) do |v|
    v.repository = Rails.root.join('git_store', 'news.git')
    v.message    = lambda { |news| news.commit_message }
    v.committer  = lambda { |news| [news.committer.public_name, news.committer.email] }
  end

  def wikified_body
    b = body_before_type_cast
    b.blank? ? "" : WikiCreole.creole_parse(b)
  end

  def wikified_second_part
    b = second_part_before_type_cast
    b.blank? ? "" : WikiCreole.creole_parse(b)
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

end
