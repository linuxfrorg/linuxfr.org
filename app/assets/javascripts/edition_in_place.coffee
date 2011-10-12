(($) ->

  class EditionInPlace
    constructor: (@el, creation: @creation) ->
      @el.data "EditionInPlace", this
      @url = @el.data("url") or (document.location.pathname + "/modifier")
      @el.click @editForm

    editForm: =>
      if @el.hasClass("locked")
        $.noticeAdd text: "Désolé, quelqu'un est déjà en train de modifier cet élément."
        return false
      @old = @el.html()
      @el.unbind "click"
      @el.load @url, =>
        form = @el.find("form")
        form.submit @submitForm
        form.find(".cancel").click @reset
        form.find("textarea, input")[0].select()
        @el.trigger "in_place:form", this
      false

    reset: (event) =>
      url = $(event.target).data("url")
      if url?
        $.ajax
          url: url
          type: "post"
          data: @el.find('input[name="authenticity_token"]').serialize()
      @el.html @old
      @el.click @editForm
      false

    submitForm: (content) =>
      form = @el.find("form")
      $.ajax
        url: form.attr("action")
        type: "post"
        data: form.serialize()
        dataType: "text"
        success: =>
          @el.trigger "in_place:result", this
          @el.click @editForm
      @el.html @old
      @el.click @editForm
      false

  $.fn.editionInPlace = ->
    @each -> new EditionInPlace($(this), creation: false)

  $.fn.creationInPlace = ->
    @each -> new EditionInPlace($(this), creation: true)

) window.jQuery
