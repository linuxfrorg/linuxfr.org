#= require push

$ = window.jQuery

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
    @board.on("mouseenter", "time", @highlitizer)
          .on("mouseleave", "time", @deshighlitizer)
    if @totoz_type == "popup"
      @totoz = @board.append($("<div id=\"les-totoz\"/>")).find("#les-totoz")
      @board.on("mouseenter", ".totoz", @createTotoz)
            .on("mouseleave", ".totoz", @destroyTotoz)
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
    r = /(\d{4}-\d{2}-\d{2} )?\d{2}:\d{2}(:\d{2})?([⁰¹²³⁴⁵⁶⁷⁸⁹]+|[:\^]\d+)?/g
    totoz = /\[:([0-9a-zA-Z \*\$@':_-]+)\]/g
    x.innerHTML = x.innerHTML.replace(r, "<time>$&</time>")
    if @totoz_type == "popup"
      x.innerHTML = x.innerHTML.replace(totoz, "<span class=\"totoz\" data-totoz-name=\"$1\">$&</span>")
    else if @totoz_type == "inline"
      x.innerHTML = x.innerHTML.replace(totoz, "<img class=\"totoz\" alt=\"$&\" title=\"$&\" src=\"#{@totoz_url}$1.gif\" style=\"vertical-align: top; background-color: transparent\"/>")

  highlitizer: (event) =>
    time = $(event.target).text()
    @inbox.find("time").filter(-> $(@).text() == time).addClass "highlighted"

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
  @each ->
    new Chat($(@))
