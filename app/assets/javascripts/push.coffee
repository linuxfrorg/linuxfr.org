#= require eventsource

$ = window.jQuery

class Push
  constructor: (@chan) ->
    @callbacks = {}
    @started = false

  on: (kind, callback) ->
    @callbacks[kind] = callback
    @

  start: ->
    if not @started
      @started = true
      $(window).load =>
        source = new EventSource("/b/#{@chan}")
        source.addEventListener "message", @onMessage
        source.addEventListener "error",   @onError
        $(window).unload -> source.close()

  onMessage: (e) =>
    try
      msg = $.parseJSON e.data
      fn  = @callbacks[msg.kind]
      fn msg  if fn?
    catch err
      console.log err  if window.console

  onError: (e) =>
    console.log "onError", e  if window.console

pushs  = []
$.push = (chan) ->
  pushs[chan] ||= new Push(chan)
