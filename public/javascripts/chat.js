/* Chat */
function newMessage(form) {
    var message = form.formToDict();
    var disabled = form.find("input[type=submit]");
    disabled.disable();
    $.postJSON("/a/message/new", message, function(response) {
        Chat.showMessage(response);
        if (message.id) {
            form.parent().remove();
        } else {
            form.find("input[type=text]").val("").select();
            disabled.enable();
        }
    });
}

jQuery.postJSON = function(url, args, callback) {
    args._xsrf = getCookie("_xsrf");
    $.ajax({url: url, data: $.param(args), dataType: "text", type: "POST",
            success: function(response) {
        if (callback) callback(eval("(" + response + ")"));
    }, error: function(response) {
        console.log("ERROR:", response)
    }});
};

jQuery.fn.formToDict = function() {
    var fields = this.serializeArray();
    var json = {}
    for (var i = 0; i < fields.length; i++) {
        json[fields[i].name] = fields[i].value;
    }
    if (json.next) delete json.next;
    return json;
};

jQuery.fn.disable = function() {
    this.enable(false);
    return this;
};

jQuery.fn.enable = function(opt_enable) {
    if (arguments.length && !opt_enable) {
        this.attr("disabled", "disabled");
    } else {
        this.removeAttr("disabled");
    }
    return this;
};

var Chat = {
    errorSleepTime: 500,
    cursor: null,
    inbox: null,
    chan: 'Free',

    create: function(inbox) {
        Chat.inbox = inbox;
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

    newMessages: function(response) {
        if (!response.messages) return;
        var messages = response.messages;
        Chat.cursor = messages[messages.length - 1].id;
        for (var i = 0; i < messages.length; i++) {
            Chat.showMessage(messages[i]);
        }
    },

    showMessage: function(message) {
//         var existing = $("#m" + message.id);
//         if (existing.length > 0) return;
        Chat.inbox.prepend(message.msg);
    }
};

// $("#messageform").live("submit", function() {
//     newMessage($(this));
//     return false;
// });
// $("#messageform").live("keypress", function(e) {
//     if (e.keyCode == 13) {
//         newMessage($(this));
//         return false;
//     }
// });
$("#message").select();
Chat.create($(".board:last"));

