# encoding: UTF-8
#
# == Schema Information
#
# Table name: wiki_pages
#
#  id          :integer(4)      not null, primary key
#  title       :string(100)     not null
#  cached_slug :string(105)
#  body        :text
#  created_at  :datetime
#  updated_at  :datetime
#

# The wiki have pages, with the content that can't go anywhere else.
#
class WikiPage < Content
  RESERVED_WORDS = %w(index nouveau modifications pages)
  has_many :versions, :class_name => 'WikiVersion',
                      :dependent  => :destroy,
                      :order      => 'version DESC',
                      :inverse_of => :wiki_page
  reserved = RESERVED_WORDS + RESERVED_WORDS.map(&:capitalize) + RESERVED_WORDS.map(&:upcase)
  validates :title, :presence  => { :message => "Le titre est obligatoire" },
                    :length    => { :maximum => 100, :message => "Le titre est trop long" },
                    :exclusion => { :in => reserved, :message => "Ce titre est réservé pour une page spéciale" }
  validates :body,  :presence  => { :message => "Le corps est obligatoire" }

  scope :sorted, order('created_at DESC')

### SEO ###

  has_friendly_id :title, :use_slug => true, :reserved_words => RESERVED_WORDS

  def normalize_friendly_id(string)
    string.to_ascii.word_chars.clean.truncate_bytes(150).with_separators.to_s
  end

### Sphinx ####

# TODO Thinking Sphinx
#   define_index do
#     indexes title, body
#     indexes user.name, :as => :user
#     where "state = 'public'"
#     set_property :field_weights => { :title => 15, :user => 1, :body => 5 }
#     set_property :delta => :datetime, :threshold => 75.minutes
#   end

### Hey, it's a wiki! ###

  attr_accessor   :wiki_body, :message, :user_id
  attr_accessible :wiki_body, :message

  before_validation :wikify_body
  def wikify_body
    return unless wiki_body
    txt = wiki_body.gsub(/\[\[\[([\w\-]+)\]\]\]/, '[\1](/wiki/\1 "Lien interne du wiki LinuxFr.org")')
    self.body = wikify(txt)
  end

  sanitize_attr :body

  after_save :create_new_version
  def create_new_version
    message ||= "révision n°#{versions.count + 1}"
    versions.create(:user_id => user_id, :body => wiki_body, :message => message)
  end

### Associated node ###

  def create_node(attrs={}, replace_existing=true)
    self.cc_licensed = true
    self.owner_id = user_id
    super
  end

### HomePage ###

  HomePage = "LinuxFr.org"
  def self.home_page
    find_by_title(HomePage)
  end

  def home_page?
    title == HomePage
  end

### ACL ###

  def creatable_by?(account)
    account && account.karma > 0
  end

  def updatable_by?(account)
    account
  end

  def destroyable_by?(account)
    account && account.amr?
  end

  def commentable_by?(account)
    account && viewable_by?(account)
  end

### Interest ###

  def self.interest_coefficient
    4
  end

end
