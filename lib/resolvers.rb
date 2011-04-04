class RedactionResolver < ::ActionView::FileSystemResolver
  def initialize
    super("app/views")
  end

  def find_templates(name, prefix, partial, details)
    super(name, prefix.sub("moderation", "redaction"), partial, details)
  end
end

class NoNamespaceResolver < ::ActionView::FileSystemResolver
  def initialize
    super("app/views")
  end

  def find_templates(name, prefix, partial, details)
    super(name, prefix.gsub(/^\w+\//, ""), partial, details)
  end
end
