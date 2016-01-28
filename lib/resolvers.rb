# encoding: utf-8
class RedactionResolver < ::ActionView::FileSystemResolver
  def initialize
    super("app/views")
  end

  def find_templates(name, prefix, partial, details, outside_app_allowed = false)
    super(name, prefix.sub("moderation", "redaction"), partial, details, outside_app_allowed)
  end
end

class NoNamespaceResolver < ::ActionView::FileSystemResolver
  def initialize
    super("app/views")
  end

  def find_templates(name, prefix, partial, details, outside_app_allowed = false)
    super(name, prefix.gsub(/^\w+\//, ""), partial, details, outside_app_allowed)
  end
end
