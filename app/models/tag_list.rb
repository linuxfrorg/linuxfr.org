require 'shellwords'

# The TagList class is used to convert a string to an array of tags.
#
class TagList < Array

  # Returns a new TagList using the given tag string.
  #
  #   taglist = TagList.new("One Two Three")
  #   taglist # => ["One", "Two", "Three"]
  def initialize(string)
    add(string.shellsplit)
  end

  # Add tags to the tag_list. Duplicate or blank tags will be ignored.
  def add(names)
    concat(names)
    clean!
    self
  end

  # Remove specific tags from the tag_list.
  def remove(names)
    delete_if { |name| names.include?(name) }
    self
  end

  # Transform the tag_list into a tag string suitable for editing in a form.
  def to_s
    join ' '
  end

private

  # Keeps only letters and digits, and remove duplicates
  def clean!
    map! {|t| t.gsub(/\P{Word}/u, '').downcase }
    reject! &:blank?
    uniq!
  end
end
