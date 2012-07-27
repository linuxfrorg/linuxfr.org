# encoding: utf-8
module AdminHelper

  def abusers
    file = Rails.root.join("tmp", "abusers.txt")
    if File.exists?(file)
      content_tag(:ul, :class => "abusers") do
        File.readlines(file).map do |l|
          content_tag(:li, l)
        end.join.html_safe
      end
    else
      content_tag(:p, "aucun")
    end
  end

end
