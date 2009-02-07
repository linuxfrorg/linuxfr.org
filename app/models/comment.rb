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
#  materialized_path :string(1022)    default(""), not null
#  created_at        :datetime
#  updated_at        :datetime
#

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :node
  has_many :relevances

  named_scope :published, :conditions => {:state => 'published'}

  validates_presence_of :title, :message => "Le titre est obligatoire"
  validates_presence_of :body,  :message => "Vous ne pouvez pas poster un commentaire vide"

### Threads ###

  def parent_id=(parent_id)
    return if parent_id.blank?
    parent = Comment.find(parent_id)
    self.materialized_path = parent ? Threads.generate_materialized_path(parent) : ''
    self.title ||= parent ? "Re: #{parent.title}" : ''
  end

  def parent_id
    Threads.get_parent_id(self)
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
