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

$ = window.jQuery

$("body").on "ajax:success", "form[data-remote]", (e, data) ->
  $.noticeAdd text: data.notice  if data and data.notice
  $("#nb_votes").text data.nb_votes   if data and data.nb_votes
  $(@).parent().hide()  unless $(@).data("hidden")

$(".markItUp").markItUp window.markItUpSettings

$("a.hit_counter[data-hit]").each ->
  @href = "/redirect/" + $(@).data("hit")

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
  $(@).parents("form").find("input[value=Prévisualiser]").next("input[type=submit]").hide()
  $(@).off event

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

$("#form_links").nested_fields "news", "link", "lien", "fieldset", title: "text", url: "url", lang: langs
$("#form_answers").nested_fields "poll", "answer", "choix", "p", answer: "text"

# Mask the contributors if they are too many
$("article.news .edited_by").each ->
  field = $(@)
  nb = field.find("a").length
  if nb > 3
    was = field.html()
    field.html "<a>#{nb} contributeurs</a>"
    field.one "click", -> field.html was

# Toolbar preferences
$("#account_visible_toolbar")
  .prop("checked", Toolbar.storage.visible != "false")
  .click ->
    Toolbar.storage.visible = $(@).is(":checked")
    true

# Show the toolbar
$.fn.reverse = [].reverse
if $("body").hasClass("logged")
  if $("#comments").length
    $("#comments .new-comment")
      .toolbar("Nouveaux commentaires", folding: "#comments .comment")
      .additional $("#comments .comment").sort((a,b) -> a.id > b.id), "Commentaires par ordre chronologique"
  else if $("main .node").length
    $("#phare .new-node, main .new-node")
      .toolbar("Contenus jamais visités")
      .additional $("#phare .new_comments, main .new_comments").parents("article").reverse(), "Contenus lus avec + de commentaires"

# Redaction
$(".edition_in_place").editionInPlace()
$("#redaction .new_link").editionInPlace()
$("#redaction .new_paragraph").on "ajax:success", false
$("#redaction .link, #redaction .paragraph").lockableEditionInPlace()

# Tags
$.fn.autocompleter = () ->
  @each ->
    input = $(@)
    input.autocomplete input.data("url"), multiple: true, multipleSeparator: " ", dataType: "text"
  @
$("input#tags").autocompleter()
$(".tag_in_place").on("in_place:form", ->
  $("input.autocomplete").autocompleter().focus()
).on("in_place:success", ->
  $.noticeAdd text: "Tags ajoutés"
).editionInPlace()
$(".add_tag, .remove_tag").click( ->
  $(@).blur().parents("form").data hidden: "true"
).parents("form").on "ajax:success", ->
  $(@).find("input").attr disabled: "disabled"

# Hotkeys
$(document).bind("keypress", "g", ->
  $("html,body").animate scrollTop: 0, 500
  false
).bind("keypress", "shift+g", ->
  $("html,body").animate scrollTop: $("body").attr("scrollHeight"), 500
  false
).bind "keypress", "shift+?", ->
  $.noticeAdd
    text: """
      Raccourcis clavier : <ul>
      <li>? pour l'aide</li>
      <li>&lt; pour le commentaire/contenu non-lu précédent</li>
      <li>&gt; pour le commentaire/contenu non-lu suivant</li>
      <li>[ pour le contenu avec commentaire précédent</li>
      <li>] pour le contenu avec commentaire suivant</li>
      <li>g pour aller au début de la page</li>
      <li>G pour aller à la fin de la page</li></ul>
      """
    stay: true
  false

$("#account_user_attributes_avatar").change ->
  return  if window.URL?
  url = window.URL.createObjectURL(@files[0])
  $(@).parents("form").find(".avatar").attr "src", url

# Admins
$("#admin_49_3").click ->
  $("#admin_49_3").hide()
  $("#buttons_49_3").show()
  false
