#= require push

(($) ->

  class Redaction
    constructor: (chan) ->
      push = $.push chan
      for name, fn of @ when name.slice(0, 2) == "on"
        kind = name.replace(/[A-Z]/g, "_$&").toLowerCase().slice(3)
        push.on kind, fn
      push.start()

    onSubmit: (msg) ->
      $.noticeAdd text: "#{msg.username} a soumis la dépêche", stay: true

    onPublish: (msg) ->
      $.noticeAdd text: "La dépêche a été acceptée par #{msg.username}", stay: true

    onRefuse: (msg) ->
      $.noticeAdd text: "La dépêche a été refusée par #{msg.username}", stay: true

    onVote: (msg) ->
      $.noticeAdd text: "#{msg.username} a voté #{msg.word}"

    onClearLocks: (msg) ->
      $(".locked").removeClass "locked"
      $.noticeAdd text: "Tous les verrous ont été supprimés"

    onUpdate: (msg) ->
      $("#news_header .title").text msg.title
      $("#news_header .topic").text msg.section.title
      $("#edition figure.image img").attr src: "/images/sections/#{msg.section.id}.png"

    liForRevision: (msg) ->
      parts = window.location.pathname.split("/")
      slug  = parts[parts.length - 1]
      """
      <li><a href="/redaction/news#{slug}/revision/#{msg.id}">
        #{msg.username}&nbsp;: #{msg.message}
      </a></li>
      """

    onRevision: (msg) =>
      $("#news_revisions ul").prepend @liForRevision(msg)

    innerHtmlForLink: (msg) ->
      """
      <a href="#{msg.url}" class="hit_counter">#{msg.title}</a> (0 clic)
      """

    htmlForLink: (msg) ->
      """
      <li class="link" id="link_#{msg.id}" lang="#{msg.lang}" data-url="/redaction/links/#{msg.id}/modifier">
        #{innerHtmlForLink msg}
      </li>
      """

    onAddLink: (msg) =>
      $("#links").append @htmlForLink(msg)
      $("#link_#{msg.id}").editionInPlace()

    onUpdateLink: (msg) =>
      $("#link_#{msg.id}").html(@innerHtmlForLink msg)
                          .attr(lang: msg.lang)
                          .removeClass "locked"

    onRemoveLink: (msg) ->
      $("#link_#{msg.id}").remove()

    onLockLink: (msg) ->
      $("#link_#{msg.id}").addClass "locked"

    htmlForPara: (msg) ->
      """
      <div id="paragraph_#{msg.id}" data-url="/redaction/paragraphs/#{msg.id}/modifier">
        #{msg.body}
      </div>
      """

    onAddParagraph: (msg) =>
      $("#paragraph_#{msg.after}").after @htmlForPara(msg)
      $("#paragraph_#{msg.id}").editionInPlace()

    onUpdateParagraph: (msg) =>
      $("#paragraph_#{msg.id}").html(msg.body)
                               .removeClass "locked"

    onRemoveParagraph: (msg) ->
      $("#paragraph_#{msg.id}").remove()

    onLockParagraph: (msg) ->
      $("#paragraph_#{msg.id}").addClass "locked"

  $.fn.redaction = ->
    @each ->
      new Redaction($(this).data("chan"))

) window.jQuery
