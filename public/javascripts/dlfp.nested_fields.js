(function($) {
    $.NestedFields = function(el, parent, nested, text, attributes) {
        var base = this;
        base.element = $(el);

        base.init = function() {
            base.parent = parent;
            base.nested = nested;
            base.text = text;
            base.attributes = attributes;
            base.create();
        };

        base.create = function() {
            var items = base.element.children('.' + base.nested);
            base.counter = items.length;
            items.each(function() { base.bind_item(this); });
            base.element.append($('<fieldset/>', {html: $('<button/>', {
                type: "button",
                id: "add_" + base.nested,
                text: "Ajouter un " + base.text
            })}));
            $('#add_' + base.nested).click(function() {
                base.add_item();
                return false;
            });
        };

        base.bind_item = function(item) {
            var it = $(item);
            it.append('<button type="button" class="remove">Supprimer ce ' + base.text + '</button>');
            it.children('.remove').click(function() { base.remove_item(it); });
        };

        base.add_item = function() {
            var last = base.element.children('.' + base.nested + ':last');
            var fset = $('<fieldset/>', {"class": base.nested});
            if (last.length == 0) {
                last = base.element.children('fieldset:first')
            }
            last.after(fset);
            for (var i in base.attributes) {
                var name = base.parent + '[' + base.nested + 's_attributes][' + base.counter + '][' + i + ']';
                var type = base.attributes[i];
                if (typeof(type) === "string") {
                    elem = $('<input/>', {name: name, type: type, size: 30, autocomplete: "off"})
                } else {
                    elem = $('<select/>', {name: name});
                    for (var j in type) {
                        $('<option/>', {value: j, text: type[j]}).appendTo(elem);
                    }
                }
                fset.append(elem).append(" ");
            }
            base.bind_item(last.next());
            base.counter += 1;
        };

        base.remove_item = function(item) {
            item.remove();
        };

        base.init();
    };

    $.fn.nested_fields = function(parent, nested, text, attributes) {
        return this.each(function() {
            (new $.NestedFields(this, parent, nested, text, attributes));
        });
    };
})(jQuery);
