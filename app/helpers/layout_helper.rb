module LayoutHelper

  def body_attr
    classes = %w(js-off)
    classes << 'logged' if current_account
    classes << current_account.role if current_account
    classes << Rails.env if Rails.env != 'production'
    { :class => classes.join(' '), :id => "#{controller.controller_name}-#{controller.action_name}" }
  end

  def check_js
    javascript_tag "document.body.className = document.body.className.replace('js-off', 'js-on');"
  end

  def logo
    img = Logo.image
    content_tag(:h1, :title => "Le logo de LinuxFr.org", :style => "background-image: url('#{img}');") do
      link_to "LinuxFr.org", '/'
    end
  end

end
