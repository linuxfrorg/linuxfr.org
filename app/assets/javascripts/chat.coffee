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
    @totoz_url  = $.cookie("totoz-url") or "https://sfw.totoz.eu/gif/"
    @norlogize      right for right in @board.find(".board-right")
    @norlogize_left left  for left  in @board.find(".board-left time").get().reverse()
    @board.on("mouseenter", ".board-left time", @left_highlitizer)
          .on("mouseleave", "time", @deshighlitizer)
    @board.on("mouseenter", ".board-right time", @right_highlitizer)
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
    @norlogize      right for right in @inbox.find(".board-right:first")
    @norlogize_left left  for left  in @inbox.find(".board-left time:first")

  postMessage: (event) =>
    form = $(event.target)
    data = form.serialize()
    @input.val("").select()
    $.ajax url: form.attr("action"), data: data, type: "POST", dataType: "script"
    false

  norloge: (event) =>
    string = $(event.target).text()
    index = $(event.target).data("clockIndex")
    if index > 1 || (index == 1 && @board.find(".board-left time[data-clock-time=\"" + $(event.target).data("clockTime") + "\"]").length > 1)
      switch index
        when 1 then string += "¹"
        when 2 then string += "²"
        when 3 then string += "³"
        else string += ":" + index
    value = @input.val()
    range = @input.caret()
    unless range.start?
      range.start = 0
      range.end = 0
    @input.val value.substr(0, range.start) + string + " " + value.substr(range.end, value.length)
    @input.caret range.start + string.length + 1
    @input.focus()

  norlogize: (x) ->
    tmp = $('<div/>')
    escape = (txt) -> tmp.text(txt).html()
    $(x).contents().filter(-> @nodeType == 3).each ->
      r = /(\d{4}-\d{2}-\d{2} )?(\d{2}:\d{2}(:\d{2})?)([⁰¹²³⁴⁵⁶⁷⁸⁹]+|[:\^]\d+)?/g
      orig = escape @data
      html = ""
      while matches = r.exec orig
        [match, datematch, timematch, minutes, index] = matches
        if index
          switch index.substr(0, 1)
            when ":", "^" then index = index.substr(1)
            when "¹" then index = 1
            when "²" then index = 2
            when "³" then index = 3
            when "⁴" then index = 4
            when "⁵" then index = 5
            when "⁶" then index = 6
            when "⁷" then index = 7
            when "⁸" then index = 8
            when "⁹" then index = 9
            else index = 1
        else
          index = 1
        stop = matches.index
        html = html + orig.slice(idx, stop) + "<time data-clock-time=\"" + timematch + "\" data-clock-index=\"" + index + "\">" + match + "</time>"
        idx = r.lastIndex
      $(@).replaceWith html+orig.slice(idx) if html
    if @totoz_type == "popup" || @totoz_type == "inline"
      cfg = @
      $(x).contents().filter(-> @nodeType == 3).each ->
        totoz = /\[:([0-9a-zA-Z \*\$@':_-]+)\]/g
        orig = escape @data
        html = ""
        while matches = totoz.exec orig
          [title, name] = matches
          stop = matches.index
          html = html + orig.slice(idx, stop) +
            if cfg.totoz_type == "popup"
              "<span class=\"totoz\" data-totoz-name=\"#{name}\">#{title}</span>"
            else if cfg.totoz_type == "inline"
              "<img class=\"totoz\" alt=\"#{title}\" title=\"#{title}\" src=\"#{cfg.totoz_url}#{name}.gif\" style=\"vertical-align: top; background-color: transparent\"/>"
          idx = totoz.lastIndex
        $(@).replaceWith html+orig.slice(idx) if html

  norlogize_left: (x) ->
    r = /((\d{4}-\d{2}-\d{2}) )?(\d{2}:\d{2}:\d{2})/g
    date = x.innerHTML.replace(r, "$2")
    time = x.innerHTML.replace(r, "$3")
    index = @board.find(".board-left time[data-clock-date=\"" + date + "\"][data-clock-time=\"" + time + "\"]").length + 1
    x.dataset.clockDate = date
    x.dataset.clockTime = time
    x.dataset.clockIndex = index

  left_highlitizer: (event) =>
    time = $(event.target).data("clockTime")
    index = $(event.target).data("clockIndex")
    @inbox.find("time[data-clock-time=\"" + time + "\"][data-clock-index=\"" + index + "\"]").addClass "highlighted"
    @inbox.find("time[data-clock-time=\"" + time.substr(0, 5) + "\"][data-clock-index=\"" + index + "\"]").addClass "highlighted"

  right_highlitizer: (event) =>
    time = $(event.target).data("clockTime")
    index = $(event.target).data("clockIndex")
    if time.length = 5
        @inbox.find("time[data-clock-time*=\"" + time + "\"]").addClass "highlighted"
    else
        @inbox.find("time[data-clock-time=\"" + time + "\"][data-clock-index=\"" + index + "\"]").addClass "highlighted"

  deshighlitizer: =>
    @inbox.find("time.highlighted").removeClass "highlighted"

  createTotoz: (event) =>
    totozName = event.target.getAttribute("data-totoz-name")
    totozId = encodeURIComponent(totozName).replace(/[%']/g, "")
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
    totozId = encodeURIComponent(event.target.getAttribute("data-totoz-name")).replace(/[%']/g, "")
    totoz = @totoz.find("#totoz-" + totozId).first()
    totoz.css display: "none"

$.fn.chat = ->
  @each ->
    new Chat($(@))
