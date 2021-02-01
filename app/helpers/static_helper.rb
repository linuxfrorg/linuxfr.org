# encoding: utf-8
module StaticHelper
  def helperify(txt)
    txt.gsub(/\{\{([a-z_]+)\}\}/) { send "helper_#{$1}" }.html_safe
  end

  def people_list(accounts)
    content_tag(:ul, class: "people-list") do
      safe_join(accounts.map do |a|
        content_tag(:li) do
          link_to avatar_img(a.user) + a.user.name, a.user
        end
      end)
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

  def helper_maintainer_list
    people_list Account.maintainer
  end

  def helper_friend_sites_list
    sites = FriendSite.all.map { |s| content_tag(:li, link_to(s.title, s.url)) }
    content_tag(:ul, safe_join(sites), class: "people-list")
  end

  def helper_responses_list
    responses = Response.all.map { |r| content_tag(:li, content_tag(:pre, r.content)) }
    content_tag(:ul, safe_join(responses))
  end
end
