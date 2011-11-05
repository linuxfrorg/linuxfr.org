(($) ->

  class EditionInPlace
    constructor: (@el) ->
      @url = @el.data("url") or (document.location.pathname + "/modifier")
      @el.click @loadForm

    loadForm: =>
      @el.unbind "click"
      @old = @el.html()
      @xhr = $.ajax(url: @url, type: "get").fail(@cantEdit).done(@showForm)
      false

    cantEdit: =>
      @el.trigger "in_place:cant_edit", @xhr
      @el.click @loadForm
      @xhr = null

    showForm: =>
      form = @el.html(@xhr.responseText).find("form")
      form.find(".cancel").click @reset
      form.find("textarea, input, select")[0].select()
      form.submit @submitForm
      @el.trigger "in_place:form", @xhr
      @xhr = null

    reset: (event) =>
      @el.html @old
      @el.click @loadForm
      @el.trigger "in_place:reset", event
      false

    submitForm: =>
      form = @el.find("form")
      url  = form.attr("action")
      data = form.serialize()
      @xhr = $.ajax(url: url, type: "post", data: data).fail(@error).done(@success)
      false

    error: =>
      @el.trigger "in_place:error", @xhr
      @xhr = null

    success: =>
      @el.html @xhr.responseText
      @el.click @loadForm
      @el.trigger "in_place:success", @xhr
      @xhr = null

  $.fn.editionInPlace = ->
    @each -> new EditionInPlace($(this))

) window.jQuery
