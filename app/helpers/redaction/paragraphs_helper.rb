module Redaction::ParagraphsHelper

  def paragraph_attr(para)
    ret = {}
    ret['data-url'] = edit_redaction_paragraph_path(para)
    ret[:class] = para.part
    ret[:class] += ' locked' if para.locked?
    ret
  end

end
