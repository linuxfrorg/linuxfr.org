# encoding: utf-8
module LayoutHelper

  def body_attr
    classes = []
    classes << 'logged' if current_account
    classes << current_account.role if current_account
    classes << "moderation_page" if controller.controller_path.starts_with?('moderation')
    { class: classes.join(' '), id: "#{controller.controller_name}-#{controller.action_name}" }
  end

  def logo
    content_tag(:h1, title: "Le logo de LinuxFr.org") do
      link_to "LinuxFr.org", '/'
    end
  end
end
