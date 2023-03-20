# encoding: UTF-8
module BookmarkHelper
  def lang(bookmark)
    detail = ""
    if bookmark.lang != 'fr'
      detail = "(en #{Lang[bookmark.lang].downcase})"
    end
    detail
  end
end
