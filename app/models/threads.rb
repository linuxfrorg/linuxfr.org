# A thread is a tree of comments, attached to a node.
# A node can have several threads.
#
# This class has some expectations:
#   * each id in the materialized path of a comment references a valid comment,
#   * a comment must have a greater id than any of its ascendant,
#   * the id of a comment can't appear in its materialized path (no circular references).
#
# Note: this class is called Threads (with a 's') and not Thread,
# because Thread is already used by the core classes of Ruby.
#
class Threads
  attr_reader :comment
  attr_reader :children

  # Build a thread with the given comments
  def initialize(comment)
    @comment  = comment
    @children = []
  end

  # Add a child
  def <<(child)
    @children << child
  end

  # Return the threads with all the comments for the given node
  def self.all(node_id)
    comments = Comment.all(:conditions => {:node_id => node_id}, :order => 'materialized_path ASC')
    comments.map {|c| self.new(c)}
  end

### Utility functions ###

  # Generate the materialized path for a comment, given its parent
  def self.generate_materialized_path(parent)
    "%s%012d" % [parent.materialized_path, parent.id]
  end

  def self.get_parent_id(comment)
    return nil if comment.materialized_path.blank?
    comment.materialized_path[0 ... 12].to_i
  end

end
