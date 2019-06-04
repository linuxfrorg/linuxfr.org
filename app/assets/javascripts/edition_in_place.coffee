$ = window.jQuery

class EditionInPlace
  constructor: (@el, @edit) ->
    @url = @el.data("url") or (document.location.pathname + "/modifier")
    @edit = @edit or @el.data("edit-element")
    @button().click @loadForm

  button: ->
    if @edit then @el.find(@edit) else @el

  loadForm: =>
    @button().off "click"
    @old = @el.html()
    @xhr = $.ajax(url: @url, type: "get", dataType: "html").fail(@cantEdit).done(@showForm)
    false

  cantEdit: =>
    @el.trigger "in_place:cant_edit", @xhr
    @button().click @loadForm
    @xhr = null
    $(".tab[data-tab-content-id=tab-board]").click()

  showForm: =>
    form = @el.html(@xhr.responseText).find("form")
    form.find(".cancel").click @reset
    form.find("textarea, input, select")[0].select()
    form.find(".markItUp").markItUp window.markItUpSettings
    form.submit @submitForm
    @el.trigger "in_place:form", @xhr
    @xhr = null
    $(".tab[data-tab-content-id=tab-help]").click()

  reset: (event) =>
    @el.html @old
    @button().click @loadForm
    @el.trigger "in_place:reset", event
    $(".tab[data-tab-content-id=tab-board]").click()
    false

  submitForm: =>
    form = @el.find("form")
    url  = form.attr("action")
    data = new FormData(form[0])
    @xhr = $.ajax(url: url, type: "post", data: data, dataType: "html", contentType: false, processData: false).fail(@error).done(@success)
    false

  error: =>
    @el.trigger "in_place:error", @xhr
    @xhr = null
    $(".tab[data-tab-content-id=tab-board]").click()

  success: =>
    @el = $(@xhr.responseText).replaceAll @el
    @button().click @loadForm
    @el.trigger "in_place:success", @xhr
    @xhr = null
    $(".tab[data-tab-content-id=tab-board]").click()

$.fn.editionInPlace = (edit_selector) ->
  @each ->
    new EditionInPlace($(@), edit_selector)
