module LinksHelper

  def link_attr(link)
    ret = {}
    ret['data-url'] = edit_redaction_link_path(link)
    ret[:class] = 'locked' if link.locked?
    ret
  end

end
