# encoding: utf-8
# == Schema Information
#
# Table name: posts
#
#  id             :integer          not null, primary key
#  forum_id       :integer
#  title          :string(160)      not null
#  cached_slug    :string(165)
#  body           :text(16777215)
#  wiki_body      :text
#  truncated_body :text
#  created_at     :datetime
#  updated_at     :datetime
#

# The post is a question in the forums.
# The users post them for seeking help.
#
class Post < Content
  self.table_name = "posts"
  self.type = "Forum"

  belongs_to :forum

  scope :with_node_ordered_by, ->(order) { joins(:node).where("nodes.public = 1").order("nodes.#{order} DESC") }

  validates :forum,     presence: { message: "Vous devez choisir un forum" }
  validates :title,     presence: { message: "Le titre est obligatoire" },
                         length: { maximum: 100, message: "Le titre est trop long" }
  validates :wiki_body, presence: { message: "Vous ne pouvez pas poster un journal vide" }

  wikify_attr   :body
  truncate_attr :body

### SEO ###

  extend FriendlyId
  friendly_id

  def should_generate_new_friendly_id?
    title_changed?
  end

### Search ####

  include Elasticsearch::Model

  scope :indexable, -> { joins(:node).where('nodes.public' => true) }

  mapping dynamic: false do
    indexes :created_at, type: 'date'
    indexes :username
    indexes :forum,      analyzer: 'keyword'
    indexes :title,      analyzer: 'french'
    indexes :body,       analyzer: 'french'
    indexes :tags,       analyzer: 'keyword'
  end

  def as_indexed_json(options={})
    {
      id: self.id,
      created_at: created_at,
      username: user.try(:name),
      forum: forum.title.tr('/.', '--'),
      title: title,
      body: body,
      tags: tag_names,
    }
  end

### ACL ###

  def updatable_by?(account)
    node.user_id == account.user_id || account.moderator? || account.admin?
  end

  def destroyable_by?(account)
    account.moderator? || account.admin?
  end

end
