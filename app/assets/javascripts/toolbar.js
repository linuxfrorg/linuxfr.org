/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const $ = window.jQuery;

class Toolbar {
  constructor(items, text, options) {
    this.next_item = this.next_item.bind(this);
    this.prev_item = this.prev_item.bind(this);
    this.alt_next_item = this.alt_next_item.bind(this);
    this.alt_prev_item = this.alt_prev_item.bind(this);
    this.change_threshold = this.change_threshold.bind(this);
    this.items = items;
    this.text = text;
    this.nb_items = this.items.length;
    this.current = 0;
    this.options = $.extend({}, Toolbar.defaultOptions, options);
    this.visible =
      (Toolbar.storage.visible || this.options.visible) !== "false";
    this.threshold = Toolbar.storage.threshold || this.options.thresholds[0];
    this.hiding();
    this.folding();
    this.create();
  }

  create() {
    if (this.visible) {
      $("body").append(`\
<div id="toolbar"><span id="toolbar_items">${this.text} :
  <span id="toolbar_current_item">${this.current}</span> /
  <span id="toolbar_nb_items">${this.nb_items}</span>
  <a href="#" accesskey="<" class="prev">&lt;</a> |
  <a href="#" accesskey=">" class="next">&gt;</a>
</span><span id="toolbar_threshold">Seuil :
  <a href="#" class="change">${this.threshold}</a>
</span></div>\
`);
      $("#toolbar_items .prev").click(this.prev_item);
      $("#toolbar_items .next").click(this.next_item);
      $("#toolbar .change").click(this.change_threshold);
    }
    return $(document)
      .bind("keypress", "<", this.prev_item)
      .bind("keypress", ">", this.next_item)
      .bind("keypress", "k", this.prev_item)
      .bind("keypress", "j", this.next_item);
  }

  next_item() {
    this.current += 1;
    if (this.current > this.nb_items) {
      this.current = 1;
    }
    return this.go_to_current();
  }

  prev_item() {
    this.current -= 1;
    if (this.current <= 0) {
      this.current = this.nb_items;
    }
    return this.go_to_current();
  }

  go_to_current() {
    if (this.nb_items === 0) {
      return;
    }
    const item = this.items[this.current - 1];
    const pos = $(item).offset().top;
    $("html,body")
      .stop()
      .animate({ scrollTop: pos }, 500);
    if (this.visible) {
      $("#toolbar_current_item").text(this.current);
    }
    return false;
  }

  additional(alt_items, alt_text) {
    this.alt_items = alt_items;
    this.alt_text = alt_text;
    this.nb_alt_items = this.alt_items.length;
    this.alt_current = 0;
    if (this.visible) {
      $("#toolbar_items").after(`\
<span id="toolbar_alt_items">${this.alt_text} :
  <span id="toolbar_current_alt_item">${this.alt_current}</span> /
  <span id="toolbar_nb_alt_items">${this.nb_alt_items}</span>
  <a href="#" accesskey="[" class="prev">[</a> |
  <a href="#" accesskey="]" class="next">]</a>
</span>\
`);
      $("#toolbar_alt_items .prev").click(this.alt_prev_item);
      $("#toolbar_alt_items .next").click(this.alt_next_item);
    }
    return $(document)
      .bind("keypress", "[", this.alt_prev_item)
      .bind("keypress", "]", this.alt_next_item)
      .bind("keypress", "h", this.alt_prev_item)
      .bind("keypress", "l", this.alt_next_item);
  }

  alt_next_item() {
    this.alt_current += 1;
    if (this.alt_current > this.nb_alt_items) {
      this.alt_current = 1;
    }
    return this.go_to_alt_current();
  }

  alt_prev_item() {
    this.alt_current -= 1;
    if (this.alt_current <= 0) {
      this.alt_current = this.nb_alt_items;
    }
    return this.go_to_alt_current();
  }

  go_to_alt_current() {
    if (this.nb_alt_items === 0) {
      return;
    }
    const item = this.alt_items[this.alt_current - 1];
    const pos = $(item).offset().top;
    $("html,body")
      .stop()
      .animate({ scrollTop: pos }, 500);
    if (this.visible) {
      $("#toolbar_current_alt_item").text(this.alt_current);
    }
    return false;
  }

  change_threshold(event) {
    const el = $(event.target);
    const ths = this.options.thresholds;
    const index = $.inArray(parseInt(el.text(), 10), ths) + 1;
    Toolbar.storage.threshold = this.threshold = ths[index % ths.length];
    el.text(this.threshold);
    this.folding();
    return false;
  }

  hiding() {
    if (this.options.folding == null) {
      return;
    }
    const items = $(this.options.folding);
    return Array.from(items).map(i =>
      (i => {
        const item = $(i);
        const score = parseInt(item.find(".score:first").text(), 10);
        const where = item.children("h2").children(".anchor");
        const close = $(
          '<a href="#" class="close" title="Cacher le fil de discussion">[-]</a>'
        ).insertBefore(where);
        close.after(" ");
        const hide = function(b) {
          if (b) {
            item.addClass("fold");
            close.text("[+]").attr("title", "Réafficher le fil de discussion");
            return item.children("ul").hide();
          } else {
            item.removeClass("fold");
            close.text("[-]").attr("title", "Cacher le fil de discussion");
            return item.children("ul").show();
          }
        };
        return close.click(function() {
          hide(close.text() === "[-]");
          return false;
        });
      })(i)
    );
  }

  folding() {
    if (this.options.folding == null) {
      return;
    }
    const items = $(this.options.folding);
    items.find(".folding").click();
    return Array.from(items).map(i =>
      (i => {
        const item = $(i);
        const score = parseInt(item.find(".score:first").text(), 10);
        if (score < this.threshold) {
          item.addClass("fold");
          const where = item.children("h2").children(".anchor");
          const link = $(
            '<a href="#" class="folding" title="Déplier">[+]</a>'
          ).insertBefore(where);
          return link.after(" ").click(function() {
            item.removeClass("fold");
            link.remove();
            return false;
          });
        }
      })(i)
    );
  }
}

Toolbar.storage = window["localStorage"] || {};

Toolbar.defaultOptions = {
  visible: true,
  folding: null,
  thresholds: [1, 2, 5, -42, 0]
};

$.fn.toolbar = function(text, options) {
  return new Toolbar($(this), text, options);
};

// Exports the Toolbar class
window.Toolbar = Toolbar;
