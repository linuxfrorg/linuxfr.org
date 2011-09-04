(($) ->

  $.NestedFields = (el, parent, nested, text, attributes) ->
    base = this
    base.element = $(el)
    base.init = ->
      base.parent = parent
      base.nested = nested
      base.text = text
      base.attributes = attributes
      base.create()

    base.create = ->
      items = base.element.children("." + base.nested)
      base.counter = items.length
      items.each -> base.bind_item this
      base.element.append $("<fieldset/>", html: $("<button/>",
        type: "button"
        id: "add_" + base.nested
        text: "Ajouter un " + base.text
      ))
      $("#add_" + base.nested).click ->
        base.add_item()
        false

    base.bind_item = (item) ->
      it = $(item)
      it.append "<button type=\"button\" class=\"remove\">Supprimer ce #{base.text} </button>"
      it.children(".remove").click ->
        base.remove_item it

    base.add_item = ->
      last = base.element.children("." + base.nested + ":last")
      fset = $("<fieldset/>", class: base.nested)
      last = base.element.children("fieldset:first")  if last.length == 0
      last.after fset
      for i of base.attributes
        name = "#{base.parent}[#{base.nested}s_attributes][#{base.counter}][#{i}]"
        type = base.attributes[i]
        if typeof (type) == "string"
          elem = $("<input/>", name: name, type: type, size: 30, autocomplete: "off")
        else
          elem = $("<select/>", name: name)
          $("<option/>", value: j, text: txt).appendTo elem  for j,txt of type
        fset.append(elem).append " "
      base.bind_item last.next()
      base.counter += 1

    base.remove_item = (item) ->
      item.remove()

    base.init()

  $.fn.nested_fields = (parent, nested, text, attributes) ->
    @each -> new $.NestedFields(this, parent, nested, text, attributes)

) window.jQuery
