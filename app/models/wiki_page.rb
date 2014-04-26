# encoding: UTF-8
# == Schema Information
#
# Table name: wiki_pages
#
#  id          :integer          not null, primary key
#  title       :string(100)      not null
#  cached_slug :string(105)
#  body        :text(16777215)
#  created_at  :datetime
#  updated_at  :datetime
#

#
# The wiki have pages, with the content that can't go anywhere else.
#
class WikiPage < Content
  self.table_name = "wiki_pages"
  self.type = "Page wiki"

  RESERVED_WORDS = %w(index nouveau modifications pages)
  has_many :versions,
    -> { order(version: :desc) },
    class_name: "WikiVersion",
    dependent: :destroy,
    inverse_of: :wiki_page
  reserved = RESERVED_WORDS + RESERVED_WORDS.map(&:capitalize) + RESERVED_WORDS.map(&:upcase)
  validates :title, presence: { message: "Le titre est obligatoire" },
                    length: { maximum: 100, message: "Le titre est trop long" },
                    exclusion: { in: reserved, message: "Ce titre est réservé pour une page spéciale" }
  validates :body,  presence: { message: "Le corps est obligatoire" }

### SEO ###

  extend FriendlyId
  friendly_id :title, reserved_words: RESERVED_WORDS

### Search ####

  include Elasticsearch::Model

  scope :indexable, -> { joins(:node).where('nodes.public' => true) }

  mapping dynamic: false do
    indexes :created_at, type: 'date'
    indexes :username
    indexes :title,      analyzer: 'french'
    indexes :body,       analyzer: 'french'
    indexes :tags,       analyzer: 'keyword'
  end

  def as_indexed_json(options={})
    {
      id: self.id,
      created_at: created_at,
      username: user.try(:name),
      title: title,
      body: body,
      tags: tag_names,
    }
  end

### Hey, it's a wiki! ###

  attr_accessor :wiki_body, :message, :user_id

  wikify_attr :body

  after_save :create_new_version
  def create_new_version
    self.message = "révision n°#{versions.count + 1}" if message.blank?
    versions.create(user_id: user_id, body: wiki_body, message: message)
  end

### Associated node ###

  def create_node(attrs={})
    self.cc_licensed = true
    self.tmp_owner_id = user_id
    super
  end

### HomePage ###

  HomePage = "LinuxFr.org"
  def self.home_page
    find_by(title: HomePage)
  end

  def home_page?
    title == HomePage
  end

### ACL ###

  def creatable_by?(account)
    account.karma > 0
  end

  def updatable_by?(account)
    account.karma > 0
  end

  def destroyable_by?(account)
    account.amr?
  end

  def too_old_for_comments?
    false
  end

### Interest ###

  def self.interest_coefficient
    4
  end

end
