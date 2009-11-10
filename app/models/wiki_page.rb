# == Schema Information
#
# Table name: wiki_pages
#
#  id          :integer(4)      not null, primary key
#  state       :string(255)     default("public"), not null
#  title       :string(255)
#  cached_slug :string(255)
#  body        :text
#  created_at  :datetime
#  updated_at  :datetime
#

# The wiki have pages, with the content that can't go anywhere else.
#
class WikiPage < Content
  has_many :versions, :class_name => 'WikiVersion', :dependent => :destroy, :order => 'version DESC'

  attr_accessible :wiki_body, :message

  validates_presence_of :title, :message => "Le titre est obligatoire"
  validates_presence_of :body,  :message => "Le corps est obligatoire"

### SEO ###

  has_friendly_id :title

### Sphinx ####

  define_index do
    indexes title, body
    indexes user.name, :as => :user
    where "state = 'public'"
    set_property :field_weights => { :title => 15, :user => 1, :body => 5 }
    set_property :delta => :datetime, :threshold => 75.minutes
  end

### Versioning ###

  attr_accessor :user_id, :wiki_body, :message

  before_validation :wikify_body
  def wikify_body
    parser = Wikitext::Parser.new(:base_heading_level => 1, :internal_link_prefix => "/wiki/")
    self.body = parser.parse(wiki_body)
  end

  after_save :create_new_version
  def create_new_version
    versions.create(:user_id => user_id, :body => wiki_body, :message => message)
  end

### HomePage ###

  HomePage = "LinuxFr.org"
  def self.home_page
    find_by_title(HomePage)
  end

### ACL ###

  def creatable_by?(user)
    user # && user.karma > 0
  end

  def editable_by?(user)
    user && (state == "public" || user.amr?)
  end

  def deletable_by?(user)
    user && user.amr?
  end

  def commentable_by?(user)
    user && readable_by?(user)
  end

### Interest ###

  def self.interest_coefficient
    5
  end

end
