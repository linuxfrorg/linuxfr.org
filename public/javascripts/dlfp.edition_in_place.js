/*global jQuery */

(function($) {
    $.EditionInPlace = function(element, creation, options) {
        var base = this;
        base.creation = creation;
        base.element = $(element);
        base.element.data("EditionInPlace", base);

        base.init = function() {
            base.url = base.element.attr('data-url') || (document.location.pathname + '/modifier');
            base.options = $.extend({}, $.EditionInPlace.defaultOptions, options);
            base.element.click(base.editForm);
        };

        base.editForm = function() {
            if (base.element.hasClass('locked')) {
                $.noticeAdd({text: "Désolé, quelqu'un est déjà en train de modifier cet élément."});
                return false;
            }
            var old = base.element.html();
            base.element.unbind('click');
            base.element.load(base.url, function() {
                var form = base.element.find('form');
                form.submit(function() {
                    base.submitForm(base.creation ? old : '');
                });
                form.find('.cancel').click(function() {
                    base.element.html(old);
                    base.element.click(base.editForm);
                    return false;
                });
                form.find('textarea, input')[0].select();
            });
        };

        base.submitForm = function(content) {
            var form = base.element.find('form');
            $.ajax({
                url: form.attr('action'),
                type: "post",
                data: form.serialize(),
                success: function() {
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
