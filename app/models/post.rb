# encoding: utf-8
# == Schema Information
#
# Table name: posts
#
#  id             :integer          not null, primary key
#  forum_id       :integer          not null
#  title          :string(160)      not null
#  cached_slug    :string(165)      not null
#  body           :text(4294967295)
#  wiki_body      :text(16777215)
#  truncated_body :text(16777215)
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

  validates_associated :forum, message: "Vous devez choisir un forum" 

  scope :with_node_ordered_by, ->(order) { joins(:node).where("nodes.public = 1").order("nodes.#{order} DESC") }

  validates :forum,     presence: { message: "Vous devez choisir un forum" }
  validates :title,     presence: { message: "Le titre est obligatoire" },
                        length: { maximum: 100, message: "Le titre est trop long" }
  validates :wiki_body, presence: { message: "Vous ne pouvez pas poster une entrée de forum vide" }

  wikify_attr   :body
  truncate_attr :body

### SEO ###

  extend FriendlyId
  friendly_id

  def should_generate_new_friendly_id?
    title_changed?
  end

### ACL ###

  def updatable_by?(account)
    node.user_id == account.user_id || account.moderator? || account.admin?
  end

  def destroyable_by?(account)
    account.moderator? || account.admin?
  end

end
