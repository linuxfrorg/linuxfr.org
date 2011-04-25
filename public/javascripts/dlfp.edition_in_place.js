(function($) {
    $.EditionInPlace = function(element, creation, options) {
        var base = this;
        base.creation = creation;
        base.element = $(element);
        base.element.data("EditionInPlace", base);

        base.init = function() {
            base.url = base.element.attr('data-url') || (document.location.pathname + '/modifier');
            base.element.click(base.editForm);
        };

        base.editForm = function() {
            if (base.element.hasClass('locked')) {
                $.noticeAdd({text: "Désolé, quelqu'un est déjà en train de modifier cet élément."});
                return false;
            }
            base.old = base.element.html();
            base.element.unbind('click');
            base.element.load(base.url, function() {
                var form = base.element.find('form');
                form.submit(function() {
                    base.submitForm(base.creation ? base.old : '');
                    return false;
                });
                form.find('.cancel').click(base.reset);
                form.find('textarea, input')[0].select();
                base.element.trigger("in_place:form", base);
            });
            return false;
        };

        base.reset = function() {
            base.element.html(base.old);
            base.element.click(base.editForm);
            return false;
        };

        base.submitForm = function(content) {
            var form = base.element.find('form');
            $.ajax({
                url: form.attr('action'),
                type: "post",
                data: form.serialize(),
                dataType: "text",
                success: function() {
                    base.element.trigger("in_place:result", base);
                    base.element.click(base.editForm);
                }
            });
            base.element.html(content);
            base.element.click(base.editForm);
            return false;
        };

        base.init();
    };

    $.fn.editionInPlace = function() {
        return this.each(function() {
            (new $.EditionInPlace(this, false));
        });
    };

    $.fn.creationInPlace = function() {
        return this.each(function() {
            (new $.EditionInPlace(this, true));
        });
    };
})(jQuery);
