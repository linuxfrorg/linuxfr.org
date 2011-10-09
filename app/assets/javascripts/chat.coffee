#= require push

(($) ->

  class Chat
    constructor: (@board) ->
      @input = @board.find("input[type=text]")
      @inbox = @board.find(".inbox")
      @chan = @board.data("chan")
      @board.find(".board-left .norloge").click @norloge
      @board.find("form").submit @postMessage
      @totoz_type = $.cookie("totoz-type")
      @totoz_url  = $.cookie("totoz-url") or "http://sfw.totoz.eu/gif/"
      @norlogize right  for right in @board.find(".board-right")
      @board.delegate("time", "mouseenter", @highlitizer)
            .delegate("time", "mouseleave", @deshighlitizer)
      if @totoz_type == "popup"
        @totoz = @board.append($("<div id=\"les-totoz\"/>")).find("#les-totoz")
        @board.delegate(".totoz", "mouseenter", @createTotoz)
              .delegate(".totoz", "mouseleave", @destroyTotoz)
      $.push(@chan).on("chat", @onChat).start()

    onChat: (msg) =>
      existing = $("#board_" + msg.id)
      return  if existing.length > 0
      @inbox.prepend(msg.message).find(".board-left:first .norloge").click @norloge
      @norlogize right for right in @inbox.find(".board-right:first")

    postMessage: (event) =>
      form = $(event.target)
      data = form.serialize()
      @input.val("").select()
      $.ajax url: form.attr("action"), data: data, type: "POST", dataType: "script"
      false

    norloge: (event) =>
      time = $(event.target).text()
      value = @input.val()
      range = @input.caret()
      unless range.start?
        range.start = 0
        range.end = 0
      @input.val value.substr(0, range.start) + time + " " + value.substr(range.end, value.length)
      @input.caret range.start + time.length + 1
      @input.focus()

    norlogize: (x) ->
      x.innerHTML = x.innerHTML.replace(/[0-2][0-9]:[0-6][0-9](:[0-6][0-9])?([⁰¹²³⁴⁵⁶⁷⁸⁹]+|[:\^][0-9]+)?/g, "<time>$&</time>")
      if @totoz_type == "popup"
        x.innerHTML = x.innerHTML.replace(/\[:([^\]]+)\]/g, "<span class=\"totoz\" data-totoz-name=\"$1\">$&</span>")
      else if @totoz_type == "inline"
        x.innerHTML = x.innerHTML.replace(/\[:([^\]]+)\]/g, "<img class=\"totoz\" alt=\"$&\" title=\"$&\" src=\"#{@totoz_url}$1.gif\" style=\"vertical-align: top; background-color: transparent\"/>")

    highlitizer: (event) =>
      time = $(event.target).text()
      @inbox.find("time").filter(-> $(this).text() == time).addClass "highlighted"

    deshighlitizer: =>
      @inbox.find("time.highlighted").removeClass "highlighted"

    createTotoz: (event) =>
      totozName = event.target.getAttribute("data-totoz-name")
      totozId = encodeURIComponent(totozName).replace(/%/g, "")
      totoz = @totoz.find("#totoz-" + totozId).first()
      if totoz.size() == 0
        totoz = $("<div id=\"totoz-#{totozId}\" class=\"totozimg\"></div>")
                .css(display: "none", position: "absolute")
                .append("<img src=\"#{@totoz_url}#{totozName}.gif\"/>")
        @totoz.append totoz
      offset = $(event.target).offset()
      [x, y] = [offset.left, offset.top]
      totoz.css "z-index": "15", display: "block", top: y + 20, left: x + 20

    destroyTotoz: (event) =>
      totozId = encodeURIComponent(event.target.getAttribute("data-totoz-name")).replace(/%/g, "")
      totoz = @totoz.find("#totoz-" + totozId).first()
      totoz.css display: "none"

  $.fn.chat = ->
    @each -> new Chat($(this))

) window.jQuery
