#= require push

$ = window.jQuery

class Redaction
  constructor: (chan) ->
    push = $.push chan
    for name, fn of @ when name.slice(0, 2) == "on"
      kind = name.replace(/[A-Z]/g, "_$&").toLowerCase().slice(3)
      push.on kind, fn
    push.start()

  onSubmit: (msg) ->
    $.noticeAdd text: "#{msg.username} a soumis le télégramme", stay: true

  onPublish: (msg) ->
    $.noticeAdd text: "Le télégramme a été accepté par #{msg.username}", stay: true

  onRefuse: (msg) ->
    $.noticeAdd text: "Le télégramme a été refusé par #{msg.username}", stay: true

  onRewrite: (msg) ->
    $.noticeAdd text: "Le télégramme a été renvoyé dans l'espace de rédaction par #{msg.username}", stay: true

  onVote: (msg) ->
    $.noticeAdd text: "#{msg.username} a voté #{msg.word}"
    $("#news_vote").load "/moderation/news/#{msg.news_id}/vote"

  onUpdate: (msg) ->
    $("#news_header .title").text msg.title
    $("#news_header .topic").text msg.section.title
    $("#edition figure.image img").attr src: "/images/sections/#{msg.section.id}.png"

  liForRevision: (msg) ->
    parts = window.location.pathname.split("/")
    slug  = parts[parts.length - 1]
    """
    <li><a href="/redaction/news/#{slug}/revisions/#{msg.version}">
      #{msg.username}&nbsp;: #{msg.message}
    </a></li>
    """

  onRevision: (msg) =>
    $("#news_revisions ul").prepend @liForRevision(msg)

  innerHtmlForLink: (msg) ->
    """
    <a href="/redirect/#{msg.id}" class="hit_counter">#{msg.title}</a> (#{msg.nb_clicks} clic#{if msg.nb_clicks > 1 then 's' else ''})
    """

  htmlForLink: (msg) ->
    """
    <li class="link" id="link_#{msg.id}" lang="#{msg.lang}" data-url="/redaction/links/#{msg.id}/modifier">
      #{@innerHtmlForLink msg}
      <div class="actions">
        <button class="edit">Modifier</button>
      </div>
    </li>
    """

  onAddLink: (msg) =>
    $("#links").append @htmlForLink(msg)
    $("#link_#{msg.id}").lockableEditionInPlace()

  onUpdateLink: (msg) =>
    $("#link_#{msg.id}").html(@innerHtmlForLink msg)
                        .attr(lang: msg.lang)

  onRemoveLink: (msg) ->
    $("#link_#{msg.id}").remove()

  htmlForPara: (msg) ->
    """
    <div id="paragraph_#{msg.id}" class="paragraph #{msg.part}" data-url="/redaction/paragraphs/#{msg.id}/modifier">
      #{msg.body}
      <div class="actions">
        <button class="edit">Modifier</button>
      </div>
    </div>
    """

  onAddParagraph: (msg) =>
    if msg.after
      $("#paragraph_#{msg.after}").after @htmlForPara(msg)
    else
      $("##{msg.part}").append @htmlForPara(msg)
    $("#paragraph_#{msg.id}").lockableEditionInPlace()

  onUpdateParagraph: (msg) =>
    $("#paragraph_#{msg.id}").html(msg.body)

  onRemoveParagraph: (msg) ->
    $("#paragraph_#{msg.id}").remove()

  onSecondPartToc: (msg) ->
    $("#second_part_toc").html(msg.toc)

$.fn.redaction = ->
  @each ->
    new Redaction($(@).data("chan"))
