/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const $ = window.jQuery;

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
      return $(window).load(() => {
        const source = new EventSource(`/b/${this.chan}`);
        source.addEventListener("message", this.onMessage);
        source.addEventListener("error", this.onError);
        return $(window).unload(() => source.close());
      });
    }
  }

  onMessage(e) {
    try {
      const msg = $.parseJSON(e.data);
      const fn = this.callbacks[msg.kind];
      if (fn != null) {
        return fn(msg);
      }
    } catch (err) {
      if (window.console) {
        return console.log(err);
      }
    }
  }

  onError(e) {
    if (window.console) {
      return console.log("onError", e);
    }
  }
}

const pushs = [];
$.push = chan => pushs[chan] || (pushs[chan] = new Push(chan));
