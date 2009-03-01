##
# This TagList class is taken from the acts_as_taggable_on plugin.
# http://github.com/mbleigh/acts-as-taggable-on/tree/master
#
class TagList < Array
  cattr_accessor :delimiter
  self.delimiter = ','

  # Returns a new TagList using the given tag string.
  #
  #   taglist = TagList.from("One , Two,  Three")
  #   taglist # => ["One", "Two", "Three"]
  def self.from(string)
    taglist = self.new
    string = string.to_s.dup

    # Parse the quoted tags
    string.gsub!(/"(.*?)"\s*#{delimiter}?\s*/) { tag_list << $1; "" }
    string.gsub!(/'(.*?)'\s*#{delimiter}?\s*/) { tag_list << $1; "" }

    taglist.add(string.split(delimiter))
    taglist
  end

  def initialize(*args)
    add(*args)
  end

  # Add tags to the tag_list. Duplicate or blank tags will be ignored.
  def add(*names)
    extract_and_apply_options!(names)
    concat(names)
    clean!
    self
  end

  # Remove specific tags from the tag_list.
  def remove(*names)
    extract_and_apply_options!(names)
    delete_if { |name| names.include?(name) }
    self
  end

  # Transform the tag_list into a tag string suitable for editing in a form.
  # The tags are joined with <tt>TagList.delimiter</tt> and quoted if necessary.
  #
  #   tag_list = TagList.new("Round", "Square,Cube")
  #   tag_list.to_s # 'Round, "Square,Cube"'
  def to_s
    list = self.map { |name| name.include?(delimiter) ? "\"#{name}\"" : name }
    list.join "#{delimiter} "
  end

private

  # Remove whitespace, duplicates, and blanks.
  def clean!
    reject!(&:blank?)
    map!(&:strip)
    uniq!
  end

  def extract_and_apply_options!(args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.assert_valid_keys :parse

    if options[:parse]
      args.map! { |a| self.class.from(a) }
    end

    args.flatten!
  end
end
