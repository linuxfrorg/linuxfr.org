$(".markItUp").markItUp(markItUpSettings);

$("a.hit-counter").each(function(idx,link) {
    link.href = "/redirect/" + link.getAttribute('data-hit');
});

/* Comments folding */
var Folding = {};
Folding.create = function(threshold) {
    var score, link;
    $('#comments .comment .folding').remove();
    $('#comments .comment').each(function(idx,comment) {
        comment = $(comment);
        score = parseInt(comment.find('.score:first').text());
        link  = comment.children('h3').prepend('<a href="#" class="folding">[-]</a>').children('.folding');
        link.toggle(
            function() { Folding.fold($(this).closest('.comment')); },
            function() { Folding.unfold($(this).closest('.comment')); }
        );
        if (score < threshold) {
            link.click();
        } else {
            Folding.unfold(comment);
        }
    });
};
Folding.unfold = function(comment) {
    comment.children('p, .content, .action').removeClass('fold');
    comment.children('h3').children('.folding').text('[-]').attr('title','Plier');
};
Folding.fold = function(comment) {
    comment.children('p, .content, .action').addClass('fold');
    comment.children('h3').children('.folding').text('[+]').attr('title','Déplier');
};

/* DLFP Toolbar */
var Toolbar = {};
Toolbar.threshold = 1;
Toolbar.items     = [];
Toolbar.nb_items  = 0;
Toolbar.current   = 0;
Toolbar.template  = '<div id="toolbar"><span id="toolbar-items">{text} : ' +
                    '  <span id="toolbar-current-item">{toolbar.current}</span> / ' +
                    '  <span id="toolbar-nb-items">{toolbar.nb_items}</span> ' +
                    '  <a href="#" accesskey="<" class="prev">&lt;</a> | ' +
                    '  <a href="#" accesskey=">" class="next">&gt;</a>' +
                    '</span><span id="toolbar-threshold">Seuil : ' +
                    '  <a href="#" class="change">{toolbar.threshold}</a>' +
                    '</span></div>';
Toolbar.create = function(items, txt) {
    Toolbar.items    = items;
    Toolbar.nb_items = items.length;
    $('body').append($.nano(Toolbar.template, {text: txt, toolbar: Toolbar}));
    $('#toolbar .prev').click(Toolbar.prev_item);
    $('#toolbar .next').click(Toolbar.next_item);
    $('#toolbar .change').click(Toolbar.change_threshold);
    /* Use the '<' and '>' to navigate in the items */
    $(document).keypress(function(e) {
        if ($(e.target).is("input")) return ;
        if (e.which == 60) return Toolbar.prev_item();
        if (e.which == 62) return Toolbar.next_item();
    });
};
Toolbar.next_item = function() {
    Toolbar.current++;
    if (Toolbar.current > Toolbar.nb_items) Toolbar.current -= Toolbar.nb_items;
    return Toolbar.go_to_current();
};
Toolbar.prev_item = function() {
    Toolbar.current--;
    if (Toolbar.current <= 0) Toolbar.current += Toolbar.nb_items;
    return Toolbar.go_to_current();
};
Toolbar.go_to_current = function() {
    if (Toolbar.nb_items == 0) return ;
    var item = Toolbar.items[Toolbar.current - 1];
    $(document).scrollTop($(item).offset().top);
    $('#toolbar-current-item').text(Toolbar.current);
    return false;
};
Toolbar.change_threshold = function() {
    var thresholds = [-42, 0, 1, 2, 5];
    var index = jQuery.inArray(parseInt($(this).text()), thresholds) + 1
    var value = thresholds[index % thresholds.length];
    $(this).text(value);
    Folding.create(value);
    return false;
};

/* Show the toolbar */
if ($('body').hasClass('logged')) {
    if ($('#comments').length > 0) Toolbar.create($('#comments .new-comment'), 'Nouveaux commentaires');
    if ($('#contents').length > 0) Toolbar.create($('#contents .new-content'), 'Contenus pas encore visités');
}

/* Fold/unfold comments */
Folding.create(Toolbar.threshold);

