(function($) {
    $('body').delegate('form[data-remote]', 'ajax:success', function(e, data) {
        if (data && data.notice) {
            jQuery.noticeAdd({text: data.notice});
        }
        if (data && data.nb_votes) {
            $("#nb_votes").text(data.nb_votes);
        }
        if (!$(this).data('hidden')) {
            $(this).parent().hide();
        }
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
        if ($('#comments').length) {
            $('#comments .new-comment').toolbar('Nouveaux commentaires', {folding: '#comments .comment'});
        } else if ($('#contents .node').length) {
            $('#phare .new-node, #contents .new-node').toolbar('Contenus jamais visités')
                                                      .additional($('#phare .new_comments, #contents .new_comments'), 'Contenus lus avec + de commentaires');
        }
    }

    /* Redaction */
    $('.edition_in_place').editionInPlace();
    $('#redaction .link').editionInPlace();
    $('#redaction .new_link').creationInPlace();
    $('#redaction .new_paragraph').bind('ajax:success', false);

    /* Tags */
    $('.tag_in_place').bind('in_place:form', function() {
        $('input.autocomplete').each(function() {
            var input = $(this);
            input.autocomplete(input.attr('data-url'), {multiple: true, multipleSeparator: ' ', dataType: 'text'});
            input.focus();
        });
    }).bind('in_place:result', function(evt, edit_in_place) {
        $.noticeAdd({text: "Tags ajoutés"});
        edit_in_place.reset();
    }).editionInPlace();
    $('.add_tag, .remove_tag').click(function() {
        $(this).blur().parents('form').data({ hidden: "true" });
    }).parents('form').bind('ajax:success', function() {
        $(this).find('input').attr({ disabled: "disabled" });
    });

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
                    "<li>&lt; pour le commentaire/contenu non-lu précédent</li>" +
                    "<li>&gt; pour le commentaire/contenu non-lu suivant</li>" +
                    "<li>[ pour le contenu avec commentaire précédent</li>" +
                    "<li>] pour le contenu avec commentaire suivant</li>" +
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
