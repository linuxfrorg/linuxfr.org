# encoding: utf-8

# The TagList class is used to convert a string to an array of tags.
#
class TagList < Array

  # Returns a new TagList using the given tag string.
  #
  #   taglist = TagList.new("One Two Three")
  #   taglist # => ["One", "Two", "Three"]
  def initialize(string)
    add string.split(/\s+/)
  end

  # Add tags to the tag_list. Duplicate or blank tags will be ignored.
  def add(names)
    concat(names)
    clean!
    self
  end

  # Transform the tag_list into a tag string suitable for editing in a form.
  def to_s
    join ' '
  end

private

  INVALID_CHARS = /[^\p{Word}'+-]/u

  # Keeps only letters and digits, and remove duplicates
  def clean!
    map! {|t| t.gsub(INVALID_CHARS, '').downcase }
    reject! &:blank?
    uniq!
  end
end
