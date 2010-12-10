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

  def common_js
    jquery         = %w(jquery-1.4.4.min.js)
    jquery_plugins = %w(jquery.nano jquery.autocomplete jquery.markitup jquery.hotkeys jquery.notice)
    dlfp_plugins   = %w(dlfp.chat dlfp.edition_in_place dlfp.nested_fields dlfp.toolbar)
    others         = %w(markitup-markdown rails application)
    javascript_include_tag(jquery + jquery_plugins + dlfp_plugins + others)
  end

end
