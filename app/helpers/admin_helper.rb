module AdminHelper

  def abusers
    file = Rails.root.join("tmp", "abusers.txt")
    if File.exists?(file)
      content_tag(:ul) do
        safe_join File.readlines(file).map do |l|
          content_tag(:li, l)
        end
      end
    else
      content_tag(:p, "aucun")
    end
  end

end
