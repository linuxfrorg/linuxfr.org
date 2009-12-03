(function($) {
    $.EditionInPlace = function(element, options) {
        var base = this;
        base.element = $(element);
        base.element.data("EditionInPlace", base);

        base.init = function() {
            base.url = base.element.attr('data-url') || (document.location.pathname + '/modifier');
            base.options = $.extend({}, $.EditionInPlace.defaultOptions, options);
            base.element.click(base.editForm);
        };

        base.editForm = function() {
            var old = base.element.html();
            base.element.unbind('click');
            base.element.load(base.url, function(form) {
                var form = base.element.find('form')
                form.submit(base.submitForm);
                form.find('.cancel').click(function() {
                    base.element.html(old);
                    base.element.click(base.editForm);
                    return false;
                });
                form.find('textarea, input')[0].select();
            });
        };

        base.submitForm = function() {
            var form = base.element.find('form');
            $.ajax({
                url: form.attr('action'),
                type: "post",
                data: form.serialize(),
                success: function() {
                    base.element.click(base.editForm);
                }
            });
            base.element.html('');
            return false;
        };

        base.init();
    };

    $.fn.editionInPlace = function() {
        return this.each(function() {
            (new $.EditionInPlace(this));
        });
    };

    $.fn.creationInPlace = function() {
        return this.each(function() {
            (new $.EditionInPlace(this));
        });
    };
})(jQuery);
