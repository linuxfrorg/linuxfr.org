#= require jquery
#= require jquery_ujs
#= require jquery.autocomplete
#= require jquery.caret-range
#= require jquery.cookie
#= require jquery.hotkeys
#= require jquery.notice
#= require jquery.markitup
#= require markitup-markdown
#= require_tree .

(($) ->

  $("body").delegate "form[data-remote]", "ajax:success", (e, data) ->
    $.noticeAdd text: data.notice  if data and data.notice
    $("#nb_votes").text data.nb_votes   if data and data.nb_votes
    $(this).parent().hide()  unless $(this).data("hidden")

  $(".markItUp").markItUp window.markItUpSettings

  $("a.hit_counter[data-hit]").each ->
    @href = "/redirect/" + $(this).data("hit")

  # Ready to moule
  $("input[autofocus=autofocus]").focus()
  $(".board").chat()
  $("#news_revisions").redaction()

  # Animate the scrolling to a fragment
  $("a.scroll").click ->
    dst = $(@hash)
    pos = (if dst then dst.offset().top else 0)
    $("html,body").animate scrollTop: pos, 500
    false

  # Force people to preview their modified contents
  $("textarea").keypress (event) ->
    $(this).parents("form").find("input[value=Prévisualiser]").next("input[type=submit]").hide()
    $(this).unbind event

  # Add/Remove dynamically links in the news form
  langs =
    fr: "Français"
    en: "Anglais"
    de: "Allemand"
    it: "Italien"
    es: "Espagnol"
    fi: "Finnois"
    eu: "Basque"
    ja: "Japonais"
    ru: "Russe"
    pt: "Portugais"
    nl: "Néerlandais"
    da: "Danois"
    el: "Grec"
    sv: "Suédois"
    cn: "Chinois"
    pl: "Polonais"
    xx: "!? hmmm ?!"
    ct: "Catalan"
    no: "Norvégien"
    ko: "Coréen"

  $("#form_links").nested_fields "news", "link", "lien", title: "text", url: "url", lang: langs

  # Show the toolbar
  if $("body").hasClass("logged")
    if $("#comments").length
      $("#comments .new-comment").toolbar "Nouveaux commentaires", folding: "#comments .comment"
    else if $("#contents .node").length
      $("#phare .new-node, #contents .new-node")
        .toolbar("Contenus jamais visités")
        .additional $("#phare .new_comments, #contents .new_comments"), "Contenus lus avec + de commentaires"

  # Redaction
  $(".edition_in_place").editionInPlace()
  $("#redaction .new_link").editionInPlace()
  $("#redaction .new_paragraph").bind "ajax:success", false
  $("#redaction .link, #redaction .paragraph").lockableEditionInPlace()

  # Tags
  $(".tag_in_place").bind("in_place:form", ->
    $("input.autocomplete").each ->
      input = $(this)
      input.autocomplete input.data("url"), multiple: true, multipleSeparator: " ", dataType: "text"
      input.focus()
  ).bind("in_place:success", ->
    $.noticeAdd text: "Tags ajoutés"
  ).editionInPlace()
  $(".add_tag, .remove_tag").click(->
    $(this).blur().parents("form").data hidden: "true"
  ).parents("form").bind "ajax:success", ->
    $(this).find("input").attr disabled: "disabled"

  # Hotkeys
  $(document).bind("keypress", "g", ->
    $("html,body").animate scrollTop: 0, 500
    false
  ).bind("keypress", "shift+g", ->
    $("html,body").animate scrollTop: $("body").attr("scrollHeight"), 500
    false
  ).bind "keypress", "shift+?", ->
    $.noticeAdd text: "Raccourcis clavier :<ul><li>? pour l'aide</li>" + "<li>&lt; pour le commentaire/contenu non-lu précédent</li>" + "<li>&gt; pour le commentaire/contenu non-lu suivant</li>" + "<li>[ pour le contenu avec commentaire précédent</li>" + "<li>] pour le contenu avec commentaire suivant</li>" + "<li>g pour aller au début de la page</li>" + "<li>G pour aller à la fin de la page</li></ul>"
    false

  # Gravatars
  $("img[data-gravatar]").attr "src", ->
    img = $(this)
    hash = img.data("gravatar")
    size = img.attr("width")
    defa = encodeURIComponent(img.attr("src"))
    host = (if location.protocol == "http:" then "http://www.gravatar.com" else "https://secure.gravatar.com")
    img.data gravatar: null
    host + "/avatar/" + hash + ".jpg?s=" + size + "&d=" + defa

  $("#account_user_attributes_avatar").change ->
    return  if window.URL?
    url = window.URL.createObjectURL(@files[0])
    $(this).parents("form").find(".avatar").attr "src", url

  # Admins
  $("#admin_49_3").click ->
    $("#admin_49_3").hide()
    $("#buttons_49_3").show()
    false

) window.jQuery
