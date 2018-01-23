# encoding: utf-8
module CommentsHelper

  def comment_attr(comment)
    classes = %w(comment)
    classes << "score#{comment.bound_score}"
    classes << "new-comment" unless comment.read_by?(current_account)
    if v = comment.vote_by?(current_account.id)
      classes << "vote-#{v}"
    end
    classes << cycle("odd", "even", name: "comment-#{comment.parent_id}")
    { id: "comment-#{comment.id}", class: classes.join(" ") }
  end

end
