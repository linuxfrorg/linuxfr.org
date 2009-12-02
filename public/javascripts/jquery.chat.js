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

    /* Callback for moderation */
    on_moderation: function(message) {
        Chat.inbox.prepend(message);
    },

    /* Callback for lock */
    on_lock: function(message) {
        Chat.inbox.prepend(message);
    },

    /* Callback for edit */
    on_edit: function(message) {
        Chat.inbox.prepend(msg);
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
