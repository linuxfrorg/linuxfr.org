(($) ->

  $.Toolbar = (items, text, options) ->
    base = this
    base.items = items
    base.nb_items = items.length
    base.init = ->
      base.current = 0
      base.text = text
      base.options = $.extend({}, $.Toolbar.defaultOptions, options)
      base.storage = (if ("localStorage" of window and window["localStorage"] != null) then window["localStorage"] else {})
      base.threshold = base.storage.threshold or base.options.thresholds[0]
      base.folding()
      base.create()

    base.create = =>
      $("body").append """
                       <div id=\"toolbar\"><span id=\"toolbar_items\">#{@text} : 
                         <span id=\"toolbar_current_item\">#{@current}</span> / 
                         <span id=\"toolbar_nb_items\">#{@nb_items}</span>
                         <a href=\"#\" accesskey=\"<\" class=\"prev\">&lt;</a> | 
                         <a href=\"#\" accesskey=\">\" class=\"next\">&gt;</a>
                       </span><span id=\"toolbar_threshold\">Seuil :
                         <a href=\"#\" class=\"change\">#{@threshold}</a>
                       </span></div>
                       """
      $("#toolbar_items .prev").click base.prev_item
      $("#toolbar_items .next").click base.next_item
      $("#toolbar .change").click base.change_threshold
      $(document).bind("keypress", "<", -> base.prev_item())
                 .bind("keypress", "shift+>", -> base.next_item())
                 .bind("keypress", "k", -> base.prev_item())
                 .bind("keypress", "j", -> base.next_item())

    base.next_item = ->
      base.current += 1
      base.current -= base.nb_items  if base.current > base.nb_items
      base.go_to_current()

    base.prev_item = ->
      base.current -= 1
      base.current += base.nb_items  if base.current <= 0
      base.go_to_current()

    base.go_to_current = ->
      return  if base.nb_items == 0
      item = base.items[base.current - 1]
      pos = $(item).offset().top
      $("html,body").animate scrollTop: pos, 500
      $("#toolbar_current_item").text base.current
      false

    base.additional = (alt_items, alt_text) ->
      base.alt_text = alt_text
      base.alt_items = alt_items
      base.nb_alt_items = alt_items.length
      base.alt_current = 0
      $("#toolbar").prepend """
                            <span id=\"toolbar_alt_items\">#{base.alt_text} :
                              <span id=\"toolbar_current_alt_item\">#{base.alt_current}</span> / 
                              <span id=\"toolbar_nb_alt_items\">#{base.nb_alt_items}</span> 
                              <a href=\"#\" accesskey=\"[\" class=\"prev\">[</a> | 
                              <a href=\"#\" accesskey=\"]\" class=\"next\">]</a>
                            </span>
                            """
      $("#toolbar_alt_items .prev").click base.alt_prev_item
      $("#toolbar_alt_items .next").click base.alt_next_item
      $(document).bind("keypress", "[", -> base.alt_prev_item())
                 .bind("keypress", "]", -> base.alt_next_item())
                 .bind("keypress", "h", -> base.alt_prev_item())
                 .bind("keypress", "l", -> base.alt_next_item())

    base.alt_next_item = ->
      base.alt_current += 1
      base.alt_current -= base.nb_alt_items  if base.alt_current > base.nb_alt_items
      base.go_to_alt_current()

    base.alt_prev_item = ->
      base.alt_current -= 1
      base.alt_current += base.nb_alt_items  if base.alt_current <= 0
      base.go_to_alt_current()

    base.go_to_alt_current = ->
      return  if base.nb_alt_items == 0
      item = base.alt_items[base.alt_current - 1]
      pos = $(item).parents("article").offset().top
      $("html,body").animate scrollTop: pos, 500
      $("#toolbar_current_alt_item").text base.alt_current
      false

    base.change_threshold = ->
      ths = base.options.thresholds
      index = $.inArray(parseInt($(this).text(), 10), ths) + 1
      base.storage.threshold = base.threshold = ths[index % ths.length]
      $(this).text base.threshold
      base.folding()
      false

    base.folding = ->
      return  unless base.options.folding
      items = $(base.options.folding)
      items.find(".folding").remove()
      items.each ->
        item = $(this)
        score = parseInt(item.find(".score:first").text(), 10)
        link = item.children("h2").prepend("<a href=\"#\" class=\"folding\" title=\"Plier\">[-]</a>").children(".folding")
        fold = (b) ->
          if b
            item.addClass "fold"
            link.text("[+]").attr "title", "Déplier"
          else
            item.removeClass "fold"
            link.text("[-]").attr "title", "Plier"
        link.click ->
          fold link.text() == "[-]"
          false
        fold score < base.threshold

    base.init()

  $.Toolbar.defaultOptions =
    folding: null
    thresholds: [ 1, 2, 5, -42, 0 ]

  $.fn.toolbar = (text, options) ->
    new $.Toolbar($(this), text, options)

) window.jQuery
