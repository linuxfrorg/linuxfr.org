module CommentsHelper

  def comment_attrs(comment)
    attrs = { :id => "comment-#{comment.id}", :class => "comment" }
    attrs[:class] += " new-comment" unless comment.read_by?(current_user)
    attrs
  end

end
