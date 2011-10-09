#= require push

(($) ->

  class Redaction
    constructor: (chan) ->
      console.log "new Redaction: #{chan}"
      push = $.push chan
      for name, fn of @ when name.slice(0, 2) == "on"
        kind = name.replace(/[A-Z]/g, "_$&").toLowerCase().slice(3)
        push.on kind, fn
      push.start()

    onSubmit: (msg) ->
      $.noticeAdd text: msg.message, stay: true

    onPublish: (msg) ->
      $.noticeAdd text: msg.message, stay: true

    onRefuse: (msg) ->
      $.noticeAdd text: msg.message, stay: true

    onUpdate: ->
    onVote: ->
    onClearLocks: ->

    onAddLink: ->
    onUpdateLink: ->
    onRemoveLink: ->
    onLockLink: ->

    onAddParagraph: ->
    onUpdateParagraph: ->
    onRemoveParagraph: ->
    onLockParagraph: ->

    onLocking: (msg) ->
      el = @inbox.children().first()
      for clear in el.find(".clear")
        $(".locked").removeClass "locked"
        $.noticeAdd text: message

      for link in el.find(".link")
        id = $(link).data("id")
        $("#link_" + id).addClass "locked"

      for p in el.find(".paragraph")
        id = $(p).data("id")
        $("#paragraph_" + id).addClass "locked"

    onCreation: (msg) ->
      el = @inbox.children().first()
      for link in el.find(".link")
        id = $(link).data("id")
        html = "<li class=\"link\" id=\"link_#{id}\" lang=\"" +
               $(link).find("a").attr("hreflang") +
               "\" data-url=\"/redaction/links/#{id}/modifier\">#{$(link).html()}</li>"
        $("#links").append html
        $("#link_" + id).editionInPlace()

      for p in el.find(".paragraph")
        id = $(p).data("id")
        after = $(p).data("after")
        html = "<div id=\"paragraph_#{id}\" data-url=\"/redaction/paragraphs/#{id}/modifier\">" +
               $(p).html() + "</div>"
        $("#paragraph_" + after).after html
        $("#paragraph_" + id).editionInPlace()

    onEdition: (msg) ->
      el = @inbox.children().first()
      for news in el.find(".news")
        $("#news_header").html $(news).clone()

      for link in el.find(".link")
        $("#link_" + $(link).data("id")).html $(link).html()

      for p in el.find(".paragraph")
        $("#paragraph_" + $(p).data("id")).html $(p).html()

    onDeletion: (msg) ->
      el = @inbox.children().first()
      for link in el.find(".link")
        $("#link_" + $(link).data("id")).remove()
      for p in el.find(".paragraph")
        $("#paragraph_" + $(p).data("id")).remove()

  $.fn.redaction = ->
    @each ->
      new Redaction($(this).data("chan"))

) window.jQuery
