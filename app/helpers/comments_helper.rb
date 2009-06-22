module CommentsHelper

  def comment_attr(comment)
    classes = %w(comment)
    classes << "new-comment" unless comment.read_by?(current_user)
    { :id => "comment-#{comment.id}", :class => classes.join(" ") }
  end

end
