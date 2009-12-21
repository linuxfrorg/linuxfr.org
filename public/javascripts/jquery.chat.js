var Chat = {
    /* FIXME do not share these variables */
    errorSleepTime: 500,
    cursor: null,
    inbox: null,
    chan: null,

    create: function(inbox, chan) {
        Chat.inbox = inbox;
        Chat.chan = chan;
        Chat.poll();
    },

    poll: function() {
        var args = {};
        if (Chat.cursor) args.cursor = Chat.cursor;
        $.ajax({
            url: "/chat/chan/" + Chat.chan,
            type: "POST",
            dataType: "text",
            data: $.param(args),
            success: Chat.onSuccess,
            error: Chat.onError
        });
    },

    onSuccess: function(response) {
        try {
            Chat.newMessages(eval("(" + response + ")"));
            Chat.errorSleepTime = 500;
            window.setTimeout(Chat.poll, 0);
        } catch (e) {
            console.warn(e); // TODO remove this line
            Chat.onError();
        }
    },

    onError: function(response) {
        Chat.errorSleepTime *= 2;
        window.setTimeout(Chat.poll, Chat.errorSleepTime);
    },

    /* Dispatch messages to their callbacks */
    newMessages: function(response) {
        if (!response.messages) return;
        var messages = response.messages;
        Chat.cursor = messages[messages.length - 1].id;
        for (var i = 0, message; i < messages.length; i++) {
            Chat.newMessage(messages[i]);
        }
    },

    newMessage: function(message) {
        var existing = $("#board-" + message.id);
        if (existing.length > 0) return;
        var method  = 'on_' + message['type'];
        if (Chat[method]) {
            Chat[method](message.msg);
        }
    },

    /* Callback for chat */
    on_chat: function(message) {
        Chat.inbox.prepend(message);
    },

    /* Callback for indication */
    on_indication: function(message) {
        Chat.inbox.prepend(message);
    },

    /* Callback for vote */
    on_vote: function(message) {
        Chat.inbox.prepend(message);
    },

    /* Callback for submission */
    on_submission: function(message) {
        Chat.inbox.prepend(message);
        $.noticeAdd({text: message, stay: true});
    },

    /* Callback for moderation */
    on_moderation: function(message) {
        Chat.inbox.prepend(message);
        $.noticeAdd({text: message, stay: true});
    },

    /* Callback for lock */
    on_lock: function(message) {
        Chat.inbox.prepend(message);
        var element = Chat.inbox.find("p:first");
        element.find(".clear").each(function() {
            $('.locked').removeClass('locked');
            $.noticeAdd({text: message});
        });
        element.find(".link").each(function() {
            var id = $(this).attr('data-id');
            $('#link_' + id).addClass('locked');
        });
        element.find(".paragraph").each(function() {
            var id = $(this).attr('data-id');
            $('#paragraph_' + id).addClass('locked');
        });
    },

    /* Callback for creation */
    on_creation: function(message) {
        Chat.inbox.prepend(message);
        var element = Chat.inbox.find("p:first");
        element.find(".link").each(function() {
            var id = $(this).attr('data-id');
            var html = '<p id="link_' + id + '" data-url="/redaction/links/' + id + '/modifier">' + $(this).html() + '</p>';
            $('#redaction .new_link').before(html);
            $('#link_' + id).editionInPlace();
        });
        element.find(".paragraph").each(function() {
            var id = $(this).attr('data-id');
            var after = $(this).attr('data-after');
            var html = '<div id="link_' + id + '" data-url="/redaction/paragraphs/' + id + '/modifier">' + $(this).html() + '</div>';
            $('#paragraph_' + after).after(html)
            $('#paragraph_' + id).editionInPlace();
        });
    },

    /* Callback for edition */
    on_edition: function(message) {
        Chat.inbox.prepend(message);
        var element = Chat.inbox.find("p:first");
        element.find(".news").each(function() {
            $('#news_header').html($(this).clone());
        });
        element.find(".link").each(function() {
            $('#link_' + $(this).attr('data-id')).html($(this).html());
        });
        element.find(".paragraph").each(function() {
            $('#paragraph_' + $(this).attr('data-id')).html($(this).html());
        });
    },

    /* Callback for deletion */
    on_deletion: function(message) {
        Chat.inbox.prepend(message);
        var element = Chat.inbox.find("p:first");
        element.find(".link").each(function() {
            $('#link_' + $(this).attr('data-id')).remove();
        });
        element.find(".paragraph").each(function() {
            $('#paragraph_' + $(this).attr('data-id')).remove();
        });
    }
};

$(".board").each(function() {
    var board = $(this);
    Chat.create(board.find('.inbox'), board.attr('data-chat'));
});

/* Post a message in ajax */
$('.board form').submit(function() {
    var form = $(this);
    $.post(form.attr('action'), form.serialize(), function (response) {
        form.find("input[type=text]").val("").select();
    });
    return false;
});
