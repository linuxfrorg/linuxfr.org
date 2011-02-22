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

            base.totoz_type = $.cookie('totoz-type'); // popup or inline. if null, no totoz
            base.totoz_url = $.cookie('totoz-url');
            if (base.totoz_url == null) {
                base.totoz_url = 'http://sfw.totoz.eu/gif/';
            }

            board.find('.board-right').each(base.norlogize);
            board.find('time').live('mouseenter', base.highlitizer)
                              .live('mouseleave', base.deshighlitizer);

            if (base.totoz_type == 'popup') {
                base.totoz     = board.append($('<div id="les-totoz"/>')).find("#les-totoz");
                board.find('.totoz').live('mouseenter', base.createTotoz)
                                    .live('mouseleave', base.destroyTotoz);
            }
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
            this.innerHTML = this.innerHTML.replace(/[0-2][0-9]:[0-6][0-9](:[0-6][0-9])?([⁰¹²³⁴⁵⁶⁷⁸⁹]+|[:\^][0-9]+)?/g, '<time>$&</time>');
            if (base.totoz_type == 'popup') {
                this.innerHTML = this.innerHTML.replace(/\[:([^\]]+)\]/g, '<span class="totoz" data-totoz-name="$1">$&</span>');
            } else if (base.totoz_type == 'inline') {
                this.innerHTML = this.innerHTML.replace(/\[:([^\]]+)\]/g, '<img class="totoz" alt="$&" title="$&" src="' + base.totoz_url + '$1.gif" style="vertical-align: top; background-color: transparent"/>');
            }
        };

        base.highlitizer = function() {
            var time = $(this).text();
            base.inbox.find("time").filter(function() {
                return $(this).text() == time;
            }).addClass("highlighted");
        }

        base.deshighlitizer = function() {
            base.inbox.find("time.highlighted").removeClass("highlighted");
        }

        base.createTotoz = function(e) {
            var totozName = this.getAttribute("data-totoz-name");
            var totozId = encodeURIComponent(totozName).replace(/%/g, '');
            var totoz = base.totoz.find("#totoz-" + totozId).first();
            if (totoz.size() == 0) {
                totoz = $('<div id="totoz-' + totozId + '" class="totozimg"></div>')
                            .css('display', 'none')
                            .css('position', 'absolute')
                            .append('<img src="' + base.totoz_url + totozName + '.gif"/>');
                base.totoz.append(totoz);
            }
            // Position où afficher l'image
            x = $(this).offset().left;
            y = $(this).offset().top;

            // Set the z-index of the current item,
            // make sure it's greater than the rest of thumbnail items
            // Set the position and display the image tooltip
            totoz.css({'z-index': '15', 'display': 'block', 'top': y + 20,'left': x + 20});
        }

        base.destroyTotoz = function() {
            var totozId = encodeURIComponent(this.getAttribute("data-totoz-name")).replace(/%/g, '');
            var totoz = base.totoz.find("#totoz-" + totozId).first();
            totoz.css('display', 'none');
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
                    base.inbox.find('.board-right:first').each(base.norlogize);
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
