/*global jQuery, $ */

(function($) {
    $.Chat = function(element) {
        var base = this;

        base.init = function() {
            var board      = $(element);
            base.inbox     = board.find('.inbox');
            base.chan      = board.attr('data-chat');
            base.cursor    = null;
            base.sleepTime = 500;

            board.find('form').submit(base.postMessage);
            base.poll();
        };

        base.postMessage = function() {
            var form = $(this);
            $.post(form.attr('action'), form.serialize(), function (response) {
                form.find("input[type=text]").val("").select();
            });
            return false;
        };

        /* Open a connection to the server, waiting for the next message */
        base.poll = function() {
            var args = {};
            if (base.cursor) {
                args.cursor = base.cursor;
            }
            $.ajax({
                url: "/b/" + base.chan,
                type: "GET",
                dataType: "json",
                data: $.param(args),
                success: base.onSuccess,
                error: base.onError
            });
        };

        /* We got one message (or more)! */
        base.onSuccess = function(response) {
            try {
                base.newMessages(response);
                base.sleepTime = 500;
                setTimeout(base.poll, 0);
            } catch (e) {
                base.onError();
            }
        };

        /* If we have an error, wait longer and longer between calls */
        base.onError = function() {
            base.sleepTime *= 2;
            setTimeout(base.poll, base.sleepTime);
        };

        /* Dispatch messages to their callbacks */
        base.newMessages = function(messages) {
            var message, existing, method;
            if (messages) {
                base.cursor = messages[messages.length - 1].id;
                for (var i = 0; i < messages.length; i += 1) {
                    message  = messages[i];
                    existing = $("#board_" + message.id);
                    // Anti-duplicate protection
                    if (existing.length > 0) {
                        return ;
                    }
                    method  = 'on_' + message.kind;
                    if (base[method]) {
                        base.inbox.prepend(message.msg);
                        base[method](message.msg);
                    }
                }
            }
        };

        /* Callback for chat */
        base.on_chat = function() {};

        /* Callback for indication */
        base.on_indication = function() {};

        /* Callback for vote */
        base.on_vote = function() {};

        /* Callback for submission */
        base.on_submission = function(message) {
            $.noticeAdd({text: message, stay: true});
        };

        /* Callback for moderation */
        base.on_moderation = function(message) {
            $.noticeAdd({text: message, stay: true});
        };

        /* Callback for locking */
        base.on_locking = function(message) {
            var el = base.inbox.find("p:first");
            el.find(".clear").each(function() {
                $('.locked').removeClass('locked');
                $.noticeAdd({text: message});
            });
            el.find(".link").each(function() {
                var id = $(this).attr('data-id');
                $('#link_' + id).addClass('locked');
            });
            el.find(".paragraph").each(function() {
                var id = $(this).attr('data-id');
                $('#paragraph_' + id).addClass('locked');
            });
        };

        /* Callback for creation */
        base.on_creation = function(message) {
            var el = base.inbox.find("p:first");
            el.find(".link").each(function() {
                var id = $(this).attr('data-id');
                var html = '<li id="link_' + id +
                           '" data-url="/redaction/links/' + id +
                           '/modifier">' + $(this).html() + '</li>';
                $('#links').append(html);
                $('#link_' + id).editionInPlace();
            });
            el.find(".paragraph").each(function() {
                var id = $(this).attr('data-id');
                var after = $(this).attr('data-after');
                var html = '<div id="paragraph_' + id +
                           '" data-url="/redaction/paragraphs/' + id +
                           '/modifier">' + $(this).html() + '</div>';
                $('#paragraph_' + after).after(html);
                $('#paragraph_' + id).editionInPlace();
            });
        };

        /* Callback for edition */
        base.on_edition = function(message) {
            var el = base.inbox.find("p:first");
            el.find(".news").each(function() {
                $('#news_header').html($(this).clone());
            });
            el.find(".link").each(function() {
                $('#link_' + $(this).attr('data-id')).html($(this).html());
            });
            el.find(".paragraph").each(function() {
                $('#paragraph_' + $(this).attr('data-id')).html($(this).html());
            });
        };

        /* Callback for deletion */
        base.on_deletion = function(message) {
            var el = base.inbox.find("p:first");
            el.find(".link").each(function() {
                $('#link_' + $(this).attr('data-id')).remove();
            });
            el.find(".paragraph").each(function() {
                $('#paragraph_' + $(this).attr('data-id')).remove();
            });
        };

        base.init();
    };

    $.fn.chat = function() {
        return this.each(function() {
            (new $.Chat(this));
        });
    };
})(jQuery);
