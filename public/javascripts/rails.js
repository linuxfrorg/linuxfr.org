// Adapted from http://github.com/rails/jquery-ujs
//
jQuery(function($) {
    var csrf_token = $('meta[name=csrf-token]').attr('content'),
        csrf_param = $('meta[name=csrf-param]').attr('content');

    $.fn.extend({
        triggerAndReturn: function(name, data) {
            var event = new $.Event(name);
            this.trigger(event, data);

            return event.result !== false;
        },

        callRemote: function() {
            var el      = this,
                data    = el.is('form') ? el.serializeArray() : [],
                method  = el.attr('method') || el.attr('data-method') || 'GET',
                url     = el.attr('action') || el.attr('href');

            if (url === undefined) {
                throw "No URL specified for remote call (action or href must be present).";
            } else {
                if (el.triggerAndReturn('ajax:before')) {
                    $.ajax({
                        url: url,
                        data: data,
                        dataType: 'script',
                        type: method.toUpperCase(),
                        contentType: "application/x-www-form-urlencoded",
                        beforeSend: function (xhr) {
                            el.trigger('ajax:loading', xhr);
                        },
                        success: function (data, status, xhr) {
                            el.trigger('ajax:success', [data, status, xhr]);
                        },
                        complete: function (xhr) {
                            el.trigger('ajax:complete', xhr);
                        },
                        error: function (xhr, status, error) {
                            el.trigger('ajax:failure', [xhr, status, error]);
                        }
                    });
                }

                el.trigger('ajax:after');
            }
        }
    });

    $('form[data-remote]').live('submit', function(e) {
        $(this).callRemote();
        e.preventDefault();
    });

    $('form[data-remote]').live('ajax:success', function(e, data) {
        if (data) {
            jQuery.noticeAdd({text: data});
        }
        $(this).parent().hide();
    });
});
