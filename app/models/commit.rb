# A commit is a revision of a wiki_page or a news.
# It is identified by the content and sha1 hash.
# It contains some metadata like the commit message,
# and it's possible to generate a diff from it.
#
class Commit

  def initialize(object, sha)
    @object  = object
    @version = object.version(sha)
  end

  def committer
    @version.committer.name
  end

  def message
    @version.message
  end

  def old_field(field)
    return '' if @version.parents.empty?
    field_for(field, @version.parents.first.id)
  end

  def new_field(field)
    field_for(field, @version.id)
  end

  def fields
    @object.git_settings.versioned_fields
  end

protected

  def field_for(field, id)
    @object.get_version(field, id)
  end

end
