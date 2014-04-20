# encoding: utf-8
module LayoutHelper

  def body_attr
    classes = []
    classes << 'logged' if current_account
    classes << current_account.role if current_account
    { class: classes.join(' '), id: "#{controller.controller_name}-#{controller.action_name}" }
  end

  def logo
    img = Logo.image
    content_tag(:h1, title: "Le logo de LinuxFr.org", style: "background-image: url('#{img}');") do
      link_to "LinuxFr.org", '/'
    end
  end

end
