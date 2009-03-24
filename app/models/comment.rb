# == Schema Information
# Schema version: 20090205000452
#
# Table name: comments
#
#  id                :integer(4)      not null, primary key
#  node_id           :integer(4)
#  user_id           :integer(4)
#  state             :string(255)     default("published"), not null
#  title             :string(255)
#  body              :text
#  score             :integer(4)      default(0)
#  materialized_path :string(1022)
#  created_at        :datetime
#  updated_at        :datetime
#

# The users can comment any content.
# Those comments are threaded and can be noted.
#
class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :node
  has_many :relevances

  named_scope :published, :conditions => {:state => 'published'}
  named_scope :by_content_type, lambda {|type|
    { :include => :node, :conditions => ["nodes.content_type = ?", type] }
  }

  validates_presence_of :title, :message => "Le titre est obligatoire"
  validates_presence_of :body,  :message => "Vous ne pouvez pas poster un commentaire vide"

### Threads ###

  PATH_SIZE = 12  # Each id in the materialized_path is coded on 12 chars
  MAX_DEPTH = 1022 / PATH_SIZE

  after_create :generate_materialized_path

  def generate_materialized_path
    parent = Comment.find(parent_id) if parent_id.present?
    parent_path = parent ? parent.materialized_path : ''
    self.materialized_path = "%s%0#{PATH_SIZE}d" % [parent_path, self.id]
    save
  end

  attr_reader :parent_id

  def parent_id=(parent_id)
    @parent_id = parent_id
    return if parent_id.blank?
    parent = Comment.find(parent_id)
    self.title ||= parent ? "Re: #{parent.title}" : ''
  end

  def depth
    (materialized_path.length / PATH_SIZE) - 1
  end

  def root?
    depth == 0
  end

### Body ###

  def body
    b = body_before_type_cast
    b.blank? ? "" : WikiCreole.creole_parse(b)
  end

### ACL ###

  def readable_by?(user)
    state != 'deleted' || (user && user.admin?)
  end

  def creatable_by?(user)
    node && node.content && node.content.commentable_by?(user)
  end

  def editable_by?(user)
    user && (user.moderator? || user.admin?)
  end

  def deletable_by?(user)
    user && (user.moderator? || user.admin?)
  end

  def votable_by?(user)
    user.relevances.count(:conditions => {:comment_id => id}) == 0
  end

### Workflow ###

  def mark_as_deleted!
    state = 'deleted'
    save
  end

end
