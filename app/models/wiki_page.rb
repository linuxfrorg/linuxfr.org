# == Schema Information
# Schema version: 20090216004002
#
# Table name: wiki_pages
#
#  id         :integer(4)      not null, primary key
#  state      :string(255)     default("public"), not null
#  title      :string(255)
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#

# The wiki have pages, with the content that can't go anywhere else.
#
class WikiPage < Content
  validates_presence_of :title, :message => "Le titre est obligatoire"
  validates_presence_of :body,  :message => "Le corps est obligatoire"

  wikify :body, :as => :wikified_body

### SEO ###

  has_friendly_id :title, :use_slug => true

### Versioning ###

  attr_accessor :commit_message
  attr_accessor :committer

  versioning(:title, :body) do |v|
    v.repository = Rails.root.join('git_store', 'wiki.git')
    v.message    = lambda { |page| page.commit_message }
    v.committer  = lambda { |page| [page.committer.public_name, page.committer.email] }
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

end
