(function($) {
    $.Chat = function(element) {
        var base = this;

        base.init = function() {
            var board      = $(element);
            base.input     = board.find('input[type=text]');
            base.inbox     = board.find('.inbox');
            base.chan      = board.attr('data-chat');
            base.cursor    = base.findCursor();
            base.sleepTime = 500;

            board.find('p').click(base.norloge);
            board.find('form').submit(base.postMessage);
            board.find('.board-right').each(base.norlogize);
            board.find('.horloge_ref').hover(base.highlitizer, base.deshighlitizer);
            board.find('.board-left').hover(base.highlitizer, base.deshighlitizer);
            base.poll();
        };

        base.findCursor = function() {
            var first = base.inbox.find("p:first");
            if (first.length > 0) {
                var id = first[0].id;
                return (id.slice(0,6) == "board-") ? id.slice(6) : null;
            }
            return null;
        };

        base.postMessage = function() {
            var form = $(this);
            var data = form.serialize();
            base.input.val("").select();
            $.ajax({
                url: form.attr('action'),
                data: data,
                type: 'POST',
                dataType: 'script'
            });
            return false;
        };

        base.norloge = function() {
            var time = $(this).find('.norloge').text();
            base.input.val(function(index,value) {
                return  time + ' ' + value;
            }).focus();
        };

        base.norlogize = function() {
          this.innerHTML = this.innerHTML.replace(/[0-2][0-9]:[0-6][0-9](:[0-6][0-9])?(¹[⁰¹²³⁴⁵⁶⁷⁸⁹]|[¹²³⁴⁵⁶⁷⁸⁹]|[:\^]1[0123456789]|[:\^][123456789])?/g, '<span class="horloge_ref">$&</span>');
        };

        getTime = function (element) {
          if (element.hasClass("horloge_ref")) {
            return element.text();
          }
          if (element.hasClass("board-left")) {
            return element.find("time").text();
          }
        }

        base.highlitizer = function() {
          time = getTime($(this));
          base.inbox.find(".horloge_ref")
            .filter(function() {
                                 return getTime($(this)) == time;
                               })
            .addClass("highlighted");
          base.inbox.find(".board-left")
            .filter(function() {
                                 return getTime($(this)) == time;
                               })
            .parent().addClass("highlighted");
        }

        base.deshighlitizer = function() {
          time = getTime($(this));
          base.inbox.find(".horloge_ref")
            .filter(function() {
                                 return getTime($(this)) == time;
                               })
            .removeClass("highlighted");
          base.inbox.find(".board-left")
            .filter(function() {
                                 return getTime($(this)) == time;
                               })
            .parent().removeClass("highlighted");
        }

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
                        base.inbox.prepend(message.msg)
                                  .children('p:first').click(base.norloge);
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
