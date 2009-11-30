(function($) {
    $.EditionInPlace = function(element, options) {
        var base = this;
        base.element = $(element);
        base.element.data("EditionInPlace", base);

        base.init = function() {
            base.url = base.element.attr('data-url') || document.location.pathname;
            base.options = $.extend({}, $.EditionInPlace.defaultOptions, options);
            base.element.click(base.editForm);
        };

        base.editForm = function() {
            $.ajax({
                url: base.url + '/modifier',
                type: "get",
                success: function(form) {
                    base.element.unbind('click');
                    base.element.html(form);
                    var form = base.element.find('form')
                    form.submit(base.submitForm);
                    form.find('.cancel').click(base.showHtml);
                    form.find('textarea input')[0].select();
                }
            });
        };

        base.submitForm = function() {
            $.ajax({
                url: base.url,
                type: "post",
                data: base.element.find('form').serialize(),
                success: base.showHtml
            });
            return false;
        };

        base.showHtml = function() {
            $.ajax({
                url: base.url,
                type: "get",
                success: function(html) {
                    base.element.html(html);
                    base.element.click(base.editForm);
                }
            });
        };

        base.init();
    };

    $.fn.editionInPlace = function() {
        return this.each(function() {
            (new $.EditionInPlace(this));
        });
    };

})(jQuery);

$('.edition_in_place').editionInPlace();
