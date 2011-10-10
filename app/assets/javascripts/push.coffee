(($) ->

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
        source = new EventSource("/b/#{@chan}")
        source.addEventListener "message", @onMessage
        source.addEventListener "error",   @onError

    onMessage: (e) =>
      try
        msg = $.parseJSON e.data
        console.log msg
        fn  = @callbacks[msg.kind]
        fn msg  if fn?
      catch err
        console.log err  if window.console

    onError: (e) =>
      if e.eventPhase == EventSource.CLOSED
        @started = false
        @start()

  pushs  = []
  $.push = (chan) ->
    pushs[chan] ||= new Push(chan)

) window.jQuery
