(($) ->

  $.Chat = (element) ->
    base = this
    base.init = ->
      board = $(element)
      base.input = board.find("input[type=text]")
      base.inbox = board.find(".inbox")
      base.chan = board.data("chat")
      base.cursor = base.findCursor()
      base.sleepTime = 500
      board.find(".board-left .norloge").click base.norloge
      board.find("form").submit base.postMessage
      base.totoz_type = $.cookie("totoz-type")
      base.totoz_url = $.cookie("totoz-url")
      base.totoz_url = "http://sfw.totoz.eu/gif/"  unless base.totoz_url?
      board.find(".board-right").each base.norlogize
      board.find("time").live("mouseenter", base.highlitizer).live "mouseleave", base.deshighlitizer
      if base.totoz_type == "popup"
        base.totoz = board.append($("<div id=\"les-totoz\"/>")).find("#les-totoz")
        board.find(".totoz").live("mouseenter", base.createTotoz).live "mouseleave", base.destroyTotoz
      base.poll()

    base.findCursor = ->
      first = base.inbox.children().first()
      if first.length > 0
        id = first[0].id
        return id.slice 6  if id.slice(0, 6) == "board-"
      null

    base.postMessage = ->
      form = $(this)
      data = form.serialize()
      base.input.val("").select()
      $.ajax url: form.attr("action"), data: data, type: "POST", dataType: "script"
      false

    base.norloge = ->
      time = $(this).text()
      value = base.input.val()
      range = base.input.caret()
      unless range.start?
        range.start = 0
        range.end = 0
      base.input.val value.substr(0, range.start) + time + " " + value.substr(range.end, value.length)
      base.input.caret range.start + time.length + 1
      base.input.focus()

    base.norlogize = ->
      @innerHTML = @innerHTML.replace(/[0-2][0-9]:[0-6][0-9](:[0-6][0-9])?([⁰¹²³⁴⁵⁶⁷⁸⁹]+|[:\^][0-9]+)?/g, "<time>$&</time>")
      if base.totoz_type == "popup"
        @innerHTML = @innerHTML.replace(/\[:([^\]]+)\]/g, "<span class=\"totoz\" data-totoz-name=\"$1\">$&</span>")
      else if base.totoz_type == "inline"
        @innerHTML = @innerHTML.replace(/\[:([^\]]+)\]/g, "<img class=\"totoz\" alt=\"$&\" title=\"$&\" src=\"#{base.totoz_url}$1.gif\" style=\"vertical-align: top; background-color: transparent\"/>")

    base.highlitizer = ->
      time = $(this).text()
      base.inbox.find("time").filter(->
        $(this).text() == time
      ).addClass "highlighted"

    base.deshighlitizer = ->
      base.inbox.find("time.highlighted").removeClass "highlighted"

    base.createTotoz = (e) ->
      totozName = @getAttribute("data-totoz-name")
      totozId = encodeURIComponent(totozName).replace(/%/g, "")
      totoz = base.totoz.find("#totoz-" + totozId).first()
      if totoz.size() == 0
        totoz = $("<div id=\"totoz-#{totozId}\" class=\"totozimg\"></div>")
                .css(display: "none", position: "absolute")
                .append("<img src=\"#{base.totoz_url}#{totozName}.gif\"/>")
        base.totoz.append totoz
      x = $(this).offset().left
      y = $(this).offset().top
      totoz.css "z-index": "15", display: "block", top: y + 20, left: x + 20

    base.destroyTotoz = ->
      totozId = encodeURIComponent(@getAttribute("data-totoz-name")).replace(/%/g, "")
      totoz = base.totoz.find("#totoz-" + totozId).first()
      totoz.css "display", "none"

    base.poll = ->
      args = {}
      args.cursor = base.cursor  if base.cursor
      $.ajax
        url: "/b/" + base.chan
        type: "GET"
        dataType: "json"
        data: $.param(args)
        success: base.onSuccess
        error: base.onError

    base.onSuccess = (response) ->
      try
        base.newMessages response
        base.sleepTime = 500
        setTimeout base.poll, 0
      catch e
        base.onError()

    base.onError = ->
      base.sleepTime *= 2
      setTimeout base.poll, base.sleepTime

    base.newMessages = (messages) ->
      if messages
        base.cursor = messages[messages.length - 1].id
        i = 0
        while i < messages.length
          message = messages[i]
          existing = $("#board_" + message.id)
          continue  if existing.length > 0
          method = "on_" + message.kind
          if base[method]
            base.inbox.prepend(message.msg).find(".board-left:first .norloge").click base.norloge
            base[method] message.msg
          base.inbox.find(".board-right:first").each base.norlogize
          i += 1

    base.on_chat = ->

    base.on_indication = ->

    base.on_vote = ->

    base.on_submission = (message) ->
      $.noticeAdd text: message, stay: true

    base.on_moderation = (message) ->
      $.noticeAdd text: message, stay: true

    base.on_locking = (message) ->
      el = base.inbox.children().first()
      el.find(".clear").each ->
        $(".locked").removeClass "locked"
        $.noticeAdd text: message

      el.find(".link").each ->
        id = $(this).data("id")
        $("#link_" + id).addClass "locked"

      el.find(".paragraph").each ->
        id = $(this).data("id")
        $("#paragraph_" + id).addClass "locked"

    base.on_creation = (message) ->
      el = base.inbox.children().first()
      el.find(".link").each ->
        id = $(this).data("id")
        html = "<li class=\"link\" id=\"link_#{id}\" lang=\"" +
               $(this).find("a").attr("hreflang") +
               "\" data-url=\"/redaction/links/#{id}/modifier\">#{$(this).html()}</li>"
        $("#links").append html
        $("#link_" + id).editionInPlace()

      el.find(".paragraph").each ->
        id = $(this).data("id")
        after = $(this).data("after")
        html = "<div id=\"paragraph_#{id}\" data-url=\"/redaction/paragraphs/#{id}/modifier\">" +
               $(this).html() + "</div>"
        $("#paragraph_" + after).after html
        $("#paragraph_" + id).editionInPlace()

    base.on_edition = (message) ->
      el = base.inbox.children().first()
      el.find(".news").each ->
        $("#news_header").html $(this).clone()

      el.find(".link").each ->
        $("#link_" + $(this).data("id")).html $(this).html()

      el.find(".paragraph").each ->
        $("#paragraph_" + $(this).data("id")).html $(this).html()

    base.on_deletion = (message) ->
      el = base.inbox.children().first()
      el.find(".link").each ->
        $("#link_" + $(this).data("id")).remove()
      el.find(".paragraph").each ->
        $("#paragraph_" + $(this).data("id")).remove()

    base.init()

  $.fn.chat = ->
    @each -> new $.Chat(this)

) window.jQuery
