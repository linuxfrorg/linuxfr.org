# encoding: utf-8
module ContentHelper

  def spellcheck(html)
    HTML_Spellchecker.french.spellcheck(html).html_safe
  end

  def htmldiff(was, new)
    dmp = DiffMatchPatch.new
    diff = dmp.diff_main(was, new, false)
    dmp.diff_cleanup_semantic! diff
    diff.map do |(op,txt)|
      txt.force_encoding(Encoding::UTF_8)
      txt.encode!(Encoding::UTF_8, Encoding::UTF_8) unless txt.valid_encoding?
      case op
      when  0  then h txt
      when -1  then %Q{<del class="diff">#{h txt}</del>}
      when  1  then %Q{<ins class="diff">#{h txt}</ins>}
      end
    end.join.html_safe
  end

end
