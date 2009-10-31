module StaticHelper
  def helperify(txt)
    txt.gsub(/\{\{([a-z_]+)\}\}/) { send "helper_#{$1}" }.html_safe!
  end

  def helper_admin_list
    User.admin.all.map { |user| link_to user.login, user }.to_sentence
  end

  def helper_moderator_list
    User.moderator.all.map { |user| link_to user.login, user }.to_sentence
  end

  def helper_reviewer_list
    User.reviewer.all.map { |user| link_to user.login, user }.to_sentence
  end

  def helper_responses_list
    content_tag(:ul, Response.all.map { |r| content_tag(:li, content_tag(:pre, r.content)) }.join)
  end
end
