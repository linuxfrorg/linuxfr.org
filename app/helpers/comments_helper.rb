# encoding: utf-8
module CommentsHelper

  def comment_attr(comment)
    classes = %w(comment)
    classes << "score#{comment.score}"
    classes << "new-comment" unless comment.read_by?(current_account)
    classes << cycle("odd", "even", :name => "comment-#{comment.parent_id}")
    { :id => "comment-#{comment.id}", :class => classes.join(" ") }
  end

end
