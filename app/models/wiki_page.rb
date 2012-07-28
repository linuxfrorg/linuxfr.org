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

  extend FriendlyId
  friendly_id :title, :reserved_words => RESERVED_WORDS

### Search ####

  mapping do
    indexes :id,         :index    => :not_analyzed
    indexes :created_at, :type => 'date', :include_in_all => false
    indexes :username,   :as => 'user.try(:name)', :boost => 2,            :index => 'not_analyzed'
    indexes :title,      :analyzer => 'french',    :boost => 10
    indexes :body,       :analyzer => 'french'
  end

### Hey, it's a wiki! ###

  attr_accessor   :wiki_body, :message, :user_id
  attr_accessible :wiki_body, :message

  wikify_attr   :body
  sanitize_attr :body

  after_save :create_new_version
  def create_new_version
    self.message = "révision n°#{versions.count + 1}" if message.blank?
    versions.create(:user_id => user_id, :body => wiki_body, :message => message)
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
    find_by_title(HomePage)
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

  def commentable_by?(account)
    viewable_by?(account)
  end

### Interest ###

  def self.interest_coefficient
    4
  end

end
