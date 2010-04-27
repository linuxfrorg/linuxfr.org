/*global jQuery */

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
            $('#add-' + base.nested).click(function() { base.add_item(); });
        };

        base.bind_item = function(item) {
            var it = $(item);
            it.append('<button type="button" class="remove">Supprimer ce ' + base.text + '</button>');
            it.children('.remove').click(function() { base.remove_item(it); });
        };

        base.add_item = function() {
            var last = base.element.children('.' + base.nested + ':last');
            var fset = $('<fieldset/>', {"class": base.nested});
            last.after(fset);
            for (var i in base.attributes) {
                var name = base.parent + '[' + base.nested + 's_attributes][' + base.counter + '][' + i + ']';
                $('<input/>', {name: name, type: base.attributes[i]}).appendTo(fset);
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
