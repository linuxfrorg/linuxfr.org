$ = window.jQuery

class Toolbar
  constructor: (@items, @text, options) ->
    @nb_items = @items.length
    @current  = 0
    @options  = $.extend({}, Toolbar.defaultOptions, options)
    @visible  = (Toolbar.storage.visible or @options.visible) != "false"
    @threshold = Toolbar.storage.threshold or @options.thresholds[0]
    @hiding()
    @folding()
    @create()

  create: ->
    if @visible
      $("body").append """
                       <div id="toolbar"><span id="toolbar_items">#{@text} :
                         <span id="toolbar_current_item">#{@current}</span> /
                         <span id="toolbar_nb_items">#{@nb_items}</span>
                         <a href="#" accesskey="<" class="prev">&lt;</a> |
                         <a href="#" accesskey=">" class="next">&gt;</a>
                       </span><span id="toolbar_threshold">Seuil :
                         <a href="#" class="change">#{@threshold}</a>
                       </span></div>
                       """
      $("#toolbar_items .prev").click @prev_item
      $("#toolbar_items .next").click @next_item
      $("#toolbar .change").click @change_threshold
    $(document).bind("keypress", "<", @prev_item)
               .bind("keypress", "shift+>", @next_item)
               .bind("keypress", "k", @prev_item)
               .bind("keypress", "j", @next_item)

  next_item: =>
    @current += 1
    @current = 1 if @current > @nb_items
    @go_to_current()

  prev_item: =>
    @current -= 1
    @current = @nb_items  if @current <= 0
    @go_to_current()

  go_to_current: ->
    return  if @nb_items == 0
    item = @items[@current - 1]
    pos = $(item).offset().top
    $("html,body").stop().animate scrollTop: pos, 500
    $("#toolbar_current_item").text @current  if @visible
    false

  additional: (@alt_items, @alt_text) ->
    @nb_alt_items = @alt_items.length
    @alt_current = 0
    if @visible
      $("#toolbar_items").after """
                                <span id="toolbar_alt_items">#{@alt_text} :
                                  <span id="toolbar_current_alt_item">#{@alt_current}</span> /
                                  <span id="toolbar_nb_alt_items">#{@nb_alt_items}</span>
                                  <a href="#" accesskey="[" class="prev">[</a> |
                                  <a href="#" accesskey="]" class="next">]</a>
                                </span>
                                """
      $("#toolbar_alt_items .prev").click @alt_prev_item
      $("#toolbar_alt_items .next").click @alt_next_item
    $(document).bind("keypress", "[", @alt_prev_item)
               .bind("keypress", "]", @alt_next_item)
               .bind("keypress", "h", @alt_prev_item)
               .bind("keypress", "l", @alt_next_item)

  alt_next_item: =>
    @alt_current += 1
    @alt_current = 1  if @alt_current > @nb_alt_items
    @go_to_alt_current()

  alt_prev_item: =>
    @alt_current -= 1
    @alt_current = @nb_alt_items  if @alt_current <= 0
    @go_to_alt_current()

  go_to_alt_current: ->
    return  if @nb_alt_items == 0
    item = @alt_items[@alt_current - 1]
    pos = $(item).offset().top
    $("html,body").stop().animate scrollTop: pos, 500
    $("#toolbar_current_alt_item").text @alt_current  if @visible
    false

  change_threshold: (event) =>
    el = $(event.target)
    ths = @options.thresholds
    index = $.inArray(parseInt(el.text(), 10), ths) + 1
    Toolbar.storage.threshold = @threshold = ths[index % ths.length]
    el.text @threshold
    @folding()
    false

  hiding: ->
    return  unless @options.folding?
    items = $(@options.folding)
    for i in items
      do (i) =>
        item  = $(i)
        score = parseInt(item.find(".score:first").text(), 10)
        where = item.children("h2").children(".anchor")
        close = $('<a href="#" class="close" title="Cacher le fil de discussion">[-]</a>').insertBefore(where)
        close.after(' ')
        hide = (b) ->
          if b
            item.addClass "fold"
            close.text("[+]").attr "title", "Réafficher le fil de discussion"
            item.children("ul").hide()
          else
            item.removeClass "fold"
            close.text("[-]").attr "title", "Cacher le fil de discussion"
            item.children("ul").show()
        close.click ->
          hide close.text() == "[-]"
          false

  folding: ->
    return  unless @options.folding?
    items = $(@options.folding)
    items.find(".folding").click()
    for i in items
      do (i) =>
        item  = $(i)
        score = parseInt(item.find(".score:first").text(), 10)
        if score < @threshold
          item.addClass "fold"
          where = item.children("h2").children(".anchor")
          link = $('<a href="#" class="folding" title="Plier">[+]</a>').insertBefore(where)
          link.after(' ').click ->
            item.removeClass "fold"
            link.remove()
            false

Toolbar.storage = window["localStorage"] or {}

Toolbar.defaultOptions =
  visible: true
  folding: null
  thresholds: [ 1, 2, 5, -42, 0 ]

$.fn.toolbar = (text, options) ->
  new Toolbar($(@), text, options)

# Exports the Toolbar class
window.Toolbar = Toolbar
