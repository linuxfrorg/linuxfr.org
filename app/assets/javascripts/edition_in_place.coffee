(($) ->

  $.EditionInPlace = (element, creation, options) ->
    base = this
    base.creation = creation
    base.element = $(element)
    base.element.data "EditionInPlace", base
    base.init = ->
      base.url = base.element.data("url") or (document.location.pathname + "/modifier")
      base.element.click base.editForm

    base.editForm = ->
      if base.element.hasClass("locked")
        $.noticeAdd text: "Désolé, quelqu'un est déjà en train de modifier cet élément."
        return false
      base.old = base.element.html()
      base.element.unbind "click"
      base.element.load base.url, ->
        form = base.element.find("form")
        form.submit ->
          base.submitForm (if base.creation then base.old else "")
          false
        form.find(".cancel").click base.reset
        form.find("textarea, input")[0].select()
        base.element.trigger "in_place:form", base
      false

    base.reset = ->
      base.element.html base.old
      base.element.click base.editForm
      false

    base.submitForm = (content) ->
      form = base.element.find("form")
      $.ajax
        url: form.attr("action")
        type: "post"
        data: form.serialize()
        dataType: "text"
        success: ->
          base.element.trigger "in_place:result", base
          base.element.click base.editForm
      base.element.html content
      base.element.click base.editForm
      false

    base.init()

  $.fn.editionInPlace = ->
    @each -> new $.EditionInPlace(this, false)

  $.fn.creationInPlace = ->
    @each -> new $.EditionInPlace(this, true)

) window.jQuery
