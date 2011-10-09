(($) ->

  class Push
    constructor: (@chan) ->
      @callbacks = {}

    on: (kind, callback) ->
      @callbacks[kind] = callback
      @

    start: ->
      source = new EventSource("/b/#{@chan}")
      source.addEventListener "message", @onMessage
      source.addEventListener "error",   @onError

    onMessage: (e) =>
      try
        msg = $.parseJSON e.data
        fn  = @callbacks[msg.kind]
        fn msg  if fn?
      catch err
        console.log err  if window.console

    onError: (e) =>
      @start()  if e.eventPhase == EventSource.CLOSED

  pushs  = []
  $.push = (chan) ->
    pushs[chan] ||= new Push(chan)

) window.jQuery
