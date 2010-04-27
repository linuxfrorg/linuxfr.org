/*global jQuery, markItUpSettings */

(function($) {
    $(".markItUp").markItUp(markItUpSettings);

    $("a.hit_counter").each(function() {
        this.href = "/redirect/" + $(this).attr('data-hit');
    });

    /* Ready to moule */
    // TODO $('.board').board('.inbox');
    $("#main_board input[type=text]").select();

    /* Animate the scrolling to a fragment */
    $("a.scroll").click(function() {
        var dst = $(this.hash);
        var pos = dst ? dst.offset().top : 0;
        $('html').animate({scrollTop: pos}, 500);
        return false;
    });

    $('input.autocomplete').each(function() {
        var input = $(this);
        input.autocomplete(input.attr('data-url'), {multiple: true, multipleSeparator: ' '});
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
            $('#comments .new_comment').toolbar('Nouveaux commentaires', {folding: '#comments .comment'});
        }
        if ($('#contents').length > 0) {
            $('#contents .new_content').toolbar('Contenus pas encore visités');
        }
    }

    /* Hotkeys */
    $(document)
    .bind('keypress', 'g', function() {
      $('html').animate({scrollTop: 0}, 500);
      return false;
    })
    .bind('keypress', 'shift+g', function() {
      $('html').animate({scrollTop: $('body').scrollHeight}, 500);
      return false;
    })
    .bind('keypress', 'shift+?', function() {
        // TODO complete help
        $.noticeAdd({text: "Raccourcis clavier :<ul><li>? pour l'aide</li></ul>"});
    });
})(jQuery);
