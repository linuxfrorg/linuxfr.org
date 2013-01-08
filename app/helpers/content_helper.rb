# encoding: utf-8
module ContentHelper

  def spellcheck(html)
    HTML_Spellchecker.french.spellcheck(html).html_safe
  end

  def htmldiff(was, new)
    dmp = DiffPatchMatch.new
    diffs = dmp.diff_main(was, new)
    dmp.diff_cleanupSemantic diffs
    diffs.map do |diff|
      case diff.op
      when :equal   then h diff.text
      when :delete  then %Q{<del class="diff">#{h diff.text}</del>}
      when :insert  then %Q{<ins class="diff">#{h diff.text}</ins>}
      end
    end.join.html_safe
  end

end
