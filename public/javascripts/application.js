(function($) {
    $.ajaxSettings.dataType = "json";

    $('form[data-remote]').live('ajax:success', function(e, data) {
        if (data) {
            jQuery.noticeAdd({text: data});
        }
        $(this).parent().hide();
    });

    $(".markItUp").markItUp(markItUpSettings);

    $("a.hit_counter[data-hit]").each(function() {
        this.href = "/redirect/" + $(this).attr('data-hit');
    });

    /* Ready to moule */
    $("input[autofocus=autofocus]").focus();
    $(".board").chat();

    /* Animate the scrolling to a fragment */
    $("a.scroll").click(function() {
        var dst = $(this.hash);
        var pos = dst ? dst.offset().top : 0;
        $('html,body').animate({scrollTop: pos}, 500);
        return false;
    });

    /* Force people to preview their modified contents */
    $("textarea").keypress(function(event) {
        $(this).parents("form")
               .find("input[value=Prévisualiser]")
               .next("input[type=submit]").hide();
        $(this).unbind(event);
    });

    /* Add/Remove dynamically links in the news form. */
    var langs = {
        fr: 'Français',
        en: 'Anglais',
        de: 'Allemand',
        it: 'Italien',
        es: 'Espagnol',
        fi: 'Finnois',
        eu: 'Basque',
        ja: 'Japonais',
        ru: 'Russe',
        pt: 'Portugais',
        nl: 'Néerlandais',
        da: 'Danois',
        el: 'Grec',
        sv: 'Suédois',
        cn: 'Chinois',
        pl: 'Polonais',
        xx: '!? hmmm ?!',
        ct: 'Catalan',
        no: 'Norvégien',
        ko: 'Coréen'
    };
    $("#form_links").nested_fields("news", "link", "lien", {title: 'text', url: 'url', lang: langs});

    /* Show the toolbar */
    if ($('body').hasClass('logged')) {
        if ($('#comments').length > 0) {
            $('#comments .new-comment').toolbar('Nouveaux commentaires', {folding: '#comments .comment'});
        }
        if ($('#contents .node').length > 1) {
            $('#contents .new-node').toolbar('Contenus jamais visités');
        }
    }

    /* Redaction */
    $('.edition_in_place').editionInPlace();
    $('#redaction .link').editionInPlace();
    $('#redaction .new_link').creationInPlace();

    $('.tag_in_place').live('in_place:form', function() {
        $('input.autocomplete').each(function() {
            var input = $(this);
            input.focus();
            input.autocomplete(input.attr('data-url'), {multiple: true, multipleSeparator: ' ', dataType: 'text'});
        });
    }).live('in_place:result', function() {
        $.noticeAdd({text: "Tags ajoutés"});
    }).editionInPlace();

    /* Hotkeys */
    $(document)
    .bind('keypress', 'g', function() {
        $('html,body').animate({scrollTop: 0}, 500);
        return false;
    })
    .bind('keypress', 'shift+g', function() {
        $('html,body').animate({scrollTop: $('body').attr("scrollHeight")}, 500);
        return false;
    })
    .bind('keypress', 'shift+?', function() {
        $.noticeAdd({text: "Raccourcis clavier :<ul><li>? pour l'aide</li>" +
                    "<li>&lt; pour le commentaire/contenu précédent</li>" +
                    "<li>&gt; pour le commentaire/contenu suivant</li>" +
                    "<li>g pour aller au début de la page</li>" +
                    "<li>G pour aller à la fin de la page</li></ul>"});
        return false;
    });

    /* Gravatars */
    $('img[data-gravatar]').attr("src", function() {
        var img  = $(this),
            hash = img.attr('data-gravatar'),
            size = img.attr('width'),
            defa = encodeURIComponent(img.attr('src')),
            host = location.protocol == 'http:' ? "http://www.gravatar.com" : "https://secure.gravatar.com";
        img.attr('data-gravatar', null);
        return host + "/avatar/" + hash + ".jpg?s=" + size + "&d=" + defa;
    });

    $('#account_user_attributes_avatar').change(function() {
        if (window.URL === undefined) return ;
        var url = window.URL.createObjectURL(this.files[0]);
        $(this).parents('form').find('.avatar').attr('src', url);
    });

    /* Admins */
    $("#admin_49_3").click(function() {
        $("#admin_49_3").hide();
        $("#buttons_49_3").show();
        return false;
    });
})(jQuery);
