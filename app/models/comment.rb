# == Schema Information
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
#  answered_to_self  :boolean(1)
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
  named_scope :descendants, lambda {|path|
    {:conditions => ["materialized_path LIKE ?", "#{path}_%"]}
  }
  named_scope :on_dashboard, :order => 'created_at DESC', :conditions =>
    { :state => 'published', :answered_to_self => false }

  validates_presence_of :title, :message => "Le titre est obligatoire"
  validates_presence_of :body,  :message => "Vous ne pouvez pas poster un commentaire vide"

  wikify :body

### Sphinx ####

  define_index do
    indexes title, body
    indexes user.name, :as => :user
    where "state = 'published'"
    set_property :field_weights => { :title => 5, :user => 2, :body => 1 }
    set_property :delta => :datetime, :threshold => 1.hour
  end

### Threads ###

  PATH_SIZE = 12  # Each id in the materialized_path is coded on 12 chars
  MAX_DEPTH = 1022 / PATH_SIZE

  after_create :generate_materialized_path

  def generate_materialized_path
    parent = Comment.find(parent_id) if parent_id.present?
    parent_path = parent ? parent.materialized_path : ''
    self.materialized_path = "%s%0#{PATH_SIZE}d" % [parent_path, self.id]
    self.answered_to_self  = is_an_answer_to_self?
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

  def is_an_answer_to_self?
    return false if root?
    ret = Comment.exists? ["node_id = ? AND user_id = ? AND LOCATE(materialized_path, ?) > 0 AND id != ?", node_id, user_id, materialized_path, id]
  end

### Calculations ###

  def nb_answers
    self.class.published.descendants(materialized_path).count
  end

  def last_answer
    self.class.published.descendants(materialized_path).first(:order => 'created_at DESC')
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
    user && user.relevances.count(:conditions => {:comment_id => id}) == 0
  end

### Workflow ###

  def mark_as_deleted!
    state = 'deleted'
    save
  end

end
