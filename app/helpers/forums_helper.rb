# encoding: utf-8
module ForumsHelper

  def forums_select_list
    Forum.active.sorted.map { |f| [f.title, f.id] }
  end

end
