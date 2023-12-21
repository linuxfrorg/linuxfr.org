$ = window.jQuery;

class NestedFields {
  constructor(el, parent, nested, text, tag, attributes) {
    this.add_item = this.add_item.bind(this);
    this.el = el;
    this.parent = parent;
    this.nested = nested;
    this.text = text;
    this.tag = tag;
    this.attributes = attributes;
    this.create();
  }

  create() {
    const items = this.el.children(`.${this.nested}`);
    this.counter = items.length;
    for (let i = 0; i < items.length; i++) {
      var item = items[i];
      this.bind_item(item, i);
    }
    this.el.append(
      $(`<${this.tag}/>`, {
        html: $("<button/>", {
          type: "button",
          id: `add_${this.nested}`,
          text: `Ajouter un ${this.text}`
        })
      })
    );
    $(`#add_${this.nested}`).click(this.add_item);
  }

  bind_item(item, counter) {
    const it = $(item);
    it.append(
      `<button type="button" class="remove">Supprimer ce ${this.text} </button>`
    );
    it.children(".remove").click(() => {
      if (counter) {
        const name = `${this.parent}[${
          this.nested
        }s_attributes][${counter}][_destroy]`;
        it.replaceWith($("<input/>", { name, type: "hidden", value: 1 }));
      } else {
        it.remove();
      }
      return false;
    });
  }

  add_item() {
    let last = this.el.children(`.${this.nested}:last`);
    if (last.length === 0) {
      last = this.el.children(`${this.tag}:first`);
    }
    const fset = $(`<${this.tag}/>`, { class: this.nested });
    last.after(fset);
    for (var i in this.attributes) {
      var elem;
      var type = this.attributes[i];
      var name = `${this.parent}[${this.nested}s_attributes][${
        this.counter
      }][${i}]`;
      if (typeof type === "string") {
        elem = $("<input/>", { name, type, size: 30, autocomplete: "off" });
      } else {
        elem = $("<select/>", { name });
        for (var j in type) {
          var txt = type[j];
          $("<option/>", { value: j, text: txt }).appendTo(elem);
        }
      }
      fset.append(elem).append(" ");
    }
    this.bind_item(last.next());
    this.counter += 1;
    return false;
  }
}

$.fn.nested_fields = function(parent, nested, text, tag, attributes) {
  return this.each(function() {
    return new NestedFields($(this), parent, nested, text, tag, attributes);
  });
};
