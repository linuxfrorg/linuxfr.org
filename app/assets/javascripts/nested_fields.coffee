(($) ->

  class NestedFields
    constructor: (@el, @parent, @nested, @text, @attributes) ->
      @create()

    create: ->
      items = @el.children(".#{@nested}")
      @counter = items.length
      @bind_item item  for item in items
      @el.append $("<fieldset/>", html: $("<button/>",
        type: "button"
        id: "add_#{@nested}"
        text: "Ajouter un #{@text}"
      ))
      $("#add_#{@nested}").click @add_item

    bind_item: (item) ->
      it = $(item)
      it.append "<button type=\"button\" class=\"remove\">Supprimer ce #{@text} </button>"
      it.children(".remove").click ->
        it.remove()
        false

    add_item: =>
      last = @el.children(".#{@nested}:last")
      last = @el.children("fieldset:first")  if last.length == 0
      fset = $("<fieldset/>", class: @nested)
      last.after fset
      for i,type of @attributes
        name = "#{@parent}[#{@nested}s_attributes][#{@counter}][#{i}]"
        if typeof (type) == "string"
          elem = $("<input/>", name: name, type: type, size: 30, autocomplete: "off")
        else
          elem = $("<select/>", name: name)
          $("<option/>", value: j, text: txt).appendTo elem  for j,txt of type
        fset.append(elem).append " "
      @bind_item last.next()
      @counter += 1
      false

  $.fn.nested_fields = (parent, nested, text, attributes) ->
    @each -> new NestedFields($(this), parent, nested, text, attributes)

) window.jQuery
