/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
//= require push

const $ = window.jQuery;

class Chat {
  constructor(board) {
    this.onChat = this.onChat.bind(this);
    this.postMessage = this.postMessage.bind(this);
    this.norloge = this.norloge.bind(this);
    this.left_highlitizer = this.left_highlitizer.bind(this);
    this.right_highlitizer = this.right_highlitizer.bind(this);
    this.deshighlitizer = this.deshighlitizer.bind(this);
    this.createTotoz = this.createTotoz.bind(this);
    this.destroyTotoz = this.destroyTotoz.bind(this);
    this.board = board;
    this.input = this.board.find("input[type=text]");
    this.inbox = this.board.find(".inbox");
    this.isInboxLarge = this.inbox.hasClass("large");
    this.inboxContainer = this.board.find(".inbox-container");
    this.inboxContainer.scrollTop(this.inbox.height());
    this.chan = this.board.data("chan");
    this.board.find(".board-left .norloge").click(this.norloge);
    this.board.find("form").submit(this.postMessage);
    this.totoz_type = $.cookie("totoz-type");
    this.totoz_url = $.cookie("totoz-url") || "https://totoz.eu/img/";
    for (var right of Array.from(this.board.find(".board-right"))) {
      this.norlogize(right);
    }
    for (var left of Array.from(
      this.board
        .find(".board-left time")
        .get()
        .reverse()
    )) {
      this.norlogize_left(left);
    }
    this.board
      .on("mouseenter", ".board-left time", this.left_highlitizer)
      .on("mouseleave", "time", this.deshighlitizer);
    this.board
      .on("mouseenter", ".board-right time", this.right_highlitizer)
      .on("mouseleave", "time", this.deshighlitizer);
    if (this.totoz_type === "popup") {
      this.totoz = this.board
        .append($('<div id="les-totoz"/>'))
        .find("#les-totoz");
      this.board
        .on("mouseenter", ".totoz", this.createTotoz)
        .on("mouseleave", ".totoz", this.destroyTotoz);
    }
    $.push(this.chan)
      .on("chat", this.onChat)
      .start();
  }

  onChat(msg) {
    let right;
    const existing = $("#board_" + msg.id);
    if (existing.length > 0) {
      return;
    }
    if (this.isInboxLarge) {
      this.inbox
        .append(msg.large)
        .find(".board-left:last .norloge")
        .click(this.norloge);
      this.inboxContainer.scrollTop(this.inbox.height());
      for (right of Array.from(this.inbox.find(".board-right:last"))) {
        this.norlogize(right);
      }
      return (() => {
        const result = [];
        for (var left of Array.from(this.inbox.find(".board-left time:last"))) {
          result.push(this.norlogize_left(left));
        }
        return result;
      })();
    } else {
      this.inbox
        .prepend(msg.message)
        .find(".board-left:first .norloge")
        .click(this.norloge);
      for (right of Array.from(this.inbox.find(".board-right:first"))) {
        this.norlogize(right);
      }
      return (() => {
        const result1 = [];
        for (var left of Array.from(
          this.inbox.find(".board-left time:first")
        )) {
          result1.push(this.norlogize_left(left));
        }
        return result1;
      })();
    }
  }

  postMessage(event) {
    const form = $(event.target);
    const data = form.serialize();
    this.input.val("").select();
    $.ajax({
      url: form.attr("action"),
      data,
      type: "POST",
      dataType: "script"
    });
    return false;
  }

  norloge(event) {
    let string = $(event.target).attr("norloge");
    const index = $(event.target).data("clockIndex");
    if (
      index > 1 ||
      (index === 1 &&
        this.board.find(
          '.board-left time[data-clock-time="' +
            $(event.target).data("clockTime") +
            '"]'
        ).length > 1)
    ) {
      switch (index) {
        case 1:
          string += "¹";
          break;
        case 2:
          string += "²";
          break;
        case 3:
          string += "³";
          break;
        default:
          string += ":" + index;
      }
    }
    const value = this.input.val();
    const range = this.input.caret();
    if (range.start == null) {
      range.start = 0;
      range.end = 0;
    }
    this.input.val(
      value.substr(0, range.start) +
        string +
        " " +
        value.substr(range.end, value.length)
    );
    this.input.caret(range.start + string.length + 1);
    return this.input.focus();
  }

  norlogize(x) {
    const tmp = $("<div/>");
    const escape = txt => tmp.text(txt).html();
    $(x)
      .contents()
      .filter(function() {
        return this.nodeType === 3;
      })
      .each(function() {
        let matches;
        let idx;
        const r = /(\d{4}-\d{2}-\d{2} )?(\d{2}:\d{2}(:\d{2})?)([⁰¹²³⁴⁵⁶⁷⁸⁹]+|[:\^]\d+)?/g;
        const orig = escape(this.data);
        let html = "";
        while ((matches = r.exec(orig))) {
          var [match, datematch, timematch, minutes, index] = Array.from(
            matches
          );
          if (index) {
            switch (index.substr(0, 1)) {
              case ":":
              case "^":
                index = index.substr(1);
                break;
              case "¹":
                index = 1;
                break;
              case "²":
                index = 2;
                break;
              case "³":
                index = 3;
                break;
              case "⁴":
                index = 4;
                break;
              case "⁵":
                index = 5;
                break;
              case "⁶":
                index = 6;
                break;
              case "⁷":
                index = 7;
                break;
              case "⁸":
                index = 8;
                break;
              case "⁹":
                index = 9;
                break;
              default:
                index = 1;
            }
          } else {
            index = 1;
          }
          var stop = matches.index;
          html =
            html +
            orig.slice(idx, stop) +
            '<time data-clock-time="' +
            timematch +
            '" data-clock-index="' +
            index +
            '">' +
            match +
            "</time>";
          idx = r.lastIndex;
        }
        if (html) {
          return $(this).replaceWith(html + orig.slice(idx));
        }
      });
    if (this.totoz_type === "popup" || this.totoz_type === "inline") {
      const cfg = this;
      return $(x)
        .contents()
        .filter(function() {
          return this.nodeType === 3;
        })
        .each(function() {
          let matches;
          let idx;
          const totoz = /\[:([0-9a-zA-Z \*\$@':_-]+)\]/g;
          const orig = escape(this.data);
          let html = "";
          while ((matches = totoz.exec(orig))) {
            var [title, name] = Array.from(matches);
            var stop = matches.index;
            html =
              html +
              orig.slice(idx, stop) +
              (() => {
                if (cfg.totoz_type === "popup") {
                  return `<span class=\"totoz\" data-totoz-name=\"${name}\">${title}</span>`;
                } else if (cfg.totoz_type === "inline") {
                  return `<img class=\"totoz\" alt=\"${title}\" title=\"${title}\" src=\"${
                    cfg.totoz_url
                  }${name}\" style=\"vertical-align: top; background-color: transparent\"/>`;
                }
              })();
            idx = totoz.lastIndex;
          }
          if (html) {
            return $(this).replaceWith(html + orig.slice(idx));
          }
        });
    }
  }

  norlogize_left(x) {
    const norlogeDatetime = $(x).attr("datetime");
    const date = /\d{4}-\d{2}-\d{2}/.exec(norlogeDatetime);
    const time = /\d{2}:\d{2}:\d{2}/.exec(norlogeDatetime);
    const index =
      this.board.find(
        '.board-left time[data-clock-date="' +
          date +
          '"][data-clock-time="' +
          time +
          '"]'
      ).length + 1;
    $(x).attr("data-clock-date", date);
    $(x).attr("data-clock-time", time);
    return $(x).attr("data-clock-index", index);
  }

  left_highlitizer(event) {
    const time = $(event.target).data("clockTime");
    const index = $(event.target).data("clockIndex");
    this.inbox
      .find(
        'time[data-clock-time="' + time + '"][data-clock-index="' + index + '"]'
      )
      .addClass("highlighted");
    return this.inbox
      .find(
        'time[data-clock-time="' +
          time.substr(0, 5) +
          '"][data-clock-index="' +
          index +
          '"]'
      )
      .addClass("highlighted");
  }

  right_highlitizer(event) {
    const time = $(event.target).data("clockTime");
    const index = $(event.target).data("clockIndex");
    if ((time.length = 5)) {
      return this.inbox
        .find('time[data-clock-time*="' + time + '"]')
        .addClass("highlighted");
    } else {
      return this.inbox
        .find(
          'time[data-clock-time="' +
            time +
            '"][data-clock-index="' +
            index +
            '"]'
        )
        .addClass("highlighted");
    }
  }

  deshighlitizer() {
    return this.inbox.find("time.highlighted").removeClass("highlighted");
  }

  createTotoz(event) {
    const totozName = event.target.getAttribute("data-totoz-name");
    const totozId = encodeURIComponent(totozName).replace(/[%']/g, "");
    let totoz = this.totoz.find("#totoz-" + totozId).first();
    if (totoz.size() === 0) {
      totoz = $(`<div id=\"totoz-${totozId}\" class=\"totozimg\"></div>`)
        .css({ display: "none", position: "absolute" })
        .append(`<img src=\"${this.totoz_url}${totozName}\"/>`);
      this.totoz.append(totoz);
    }
    const position = $(event.target).position();
    const [x, y] = Array.from([
      position.left,
      position.top + event.target.offsetHeight
    ]);
    return totoz.css({
      "z-index": "15",
      display: "block",
      top: y + 5,
      left: x + 5
    });
  }

  destroyTotoz(event) {
    const totozId = encodeURIComponent(
      event.target.getAttribute("data-totoz-name")
    ).replace(/[%']/g, "");
    const totoz = this.totoz.find("#totoz-" + totozId).first();
    return totoz.css({ display: "none" });
  }
}

$.fn.chat = function() {
  return this.each(function() {
    return new Chat($(this));
  });
};
