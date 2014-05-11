# encoding: utf-8
module StaticHelper
  def helperify(txt)
    txt.gsub(/\{\{([a-z_]+)\}\}/) { send "helper_#{$1}" }.html_safe
  end

  def people_list(accounts)
    content_tag(:ul, class: "people-list") do
      accounts.map do |a|
        content_tag(:li) do
          link_to avatar_img(a.user) + a.user.name, a.user
        end
      end.join.html_safe
    end
  end

  def helper_admin_list
    people_list Account.admin
  end

  def helper_editor_list
    people_list Account.editor
  end

  def helper_moderator_list
    people_list Account.moderator
  end

  def helper_responses_list
    responses = Response.all.map { |r| content_tag(:li, content_tag(:pre, r.content)) }
    content_tag(:ul, responses.join.html_safe)
  end
end
