$ = window.jQuery;

class Push {
  constructor(chan) {
    this.onMessage = this.onMessage.bind(this);
    this.onError = this.onError.bind(this);
    this.chan = chan;
    this.callbacks = {};
    this.started = false;
  }

  on(kind, callback) {
    this.callbacks[kind] = callback;
    return this;
  }

  start() {
    if (!this.started) {
      this.started = true;
      $(window).load(() => {
        const source = new EventSource(`/b/${this.chan}`);
        source.addEventListener("message", this.onMessage);
        source.addEventListener("error", this.onError);
        $(window).unload(() => source.close());
      });
    }
  }

  onMessage(e) {
    try {
      const msg = $.parseJSON(e.data);
      const fn = this.callbacks[msg.kind];
      if (fn) {
        fn(msg);
      }
    } catch (err) {
      if (window.console) {
        console.log(err);
      }
    }
  }

  onError(e) {
    if (window.console) {
      console.log("onError", e);
    }
  }
}

const pushs = [];
$.push = chan => pushs[chan] || (pushs[chan] = new Push(chan));
