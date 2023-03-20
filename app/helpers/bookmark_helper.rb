# encoding: UTF-8
module BookmarkHelper
  def lang(bookmark)
    detail = ""
    detail += "(en #{Lang[bookmark.lang].downcase})" unless bookmark.lang == 'fr'
  end
end
