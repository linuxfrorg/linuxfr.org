$ = window.jQuery

class NestedFields
  constructor: (@el, @parent, @nested, @text, @tag, @attributes) ->
    @create()

  create: ->
    items = @el.children(".#{@nested}")
    @counter = items.length
    @bind_item item, i  for item, i in items
    @el.append $("<#{@tag}/>", html: $("<button/>",
      type: "button"
      id: "add_#{@nested}"
      text: "Ajouter un #{@text}"
    ))
    $("#add_#{@nested}").click @add_item

  bind_item: (item, counter) ->
    it = $(item)
    it.append """<button type="button" class="remove">Supprimer ce #{@text} </button>"""
    it.children(".remove").click =>
      if counter
        name = "#{@parent}[#{@nested}s_attributes][#{counter}][_destroy]"
        it.replaceWith $("<input/>", name: name, type: "hidden", value: 1)
      else
        it.remove()
      false

  add_item: =>
    last = @el.children(".#{@nested}:last")
    last = @el.children("#{@tag}:first")  if last.length == 0
    fset = $("<#{@tag}/>", class: @nested)
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

$.fn.nested_fields = (parent, nested, text, tag, attributes) ->
  @each ->
    new NestedFields($(@), parent, nested, text, tag, attributes)
