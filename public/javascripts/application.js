/* jQuery extensions */
//  TODO remove these lines?
// $.fn.disable = function() {
//     this.removeAttr("disabled");
//     return this;
// };
// 
// $.fn.enable = function() {
//     this.attr("disabled", "disabled");
//     return this;
// };

/* Misc */
$(".markItUp").markItUp(markItUpSettings);

$("a.hit-counter").each(function() {
    var link = $(this);
    link.href = "/redirect/" + link.attr('data-hit');
});

/* Ready to moule */
// TODO $('.board').board('.inbox');
$("#main-board input[type=text]").select();

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

/* Comments folding */
var Folding = {};
Folding.create = function(threshold) {
    var score, link;
    $('#comments .comment .folding').remove();
    $('#comments .comment').each(function() {
        comment = $(this);
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
    comment.children('.meta, .image, .content, .actions').removeClass('fold');
    comment.children('h3').children('.folding').text('[-]').attr('title','Plier');
};
Folding.fold = function(comment) {
    comment.children('.meta, .image, .content, .actions').addClass('fold');
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
    if (localStorage.threshold)
        Toolbar.threshold = parseInt(localStorage.threshold, 10);
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
    var pos = $(item).offset().top;
    $('html').animate({scrollTop: pos}, 500);
    $('#toolbar-current-item').text(Toolbar.current);
    return false;
};
Toolbar.change_threshold = function() {
    var thresholds = [-42, 0, 1, 2, 5];
    var index = jQuery.inArray(parseInt($(this).text()), thresholds) + 1
    var value = thresholds[index % thresholds.length];
    localStorage.threshold = value;
    $(this).text(value);
    Folding.create(value);
    return false;
};

/* Add/Remove dynamically links in the news form. */
var FormLinks = {};
FormLinks.div;
FormLinks.counter  = 0;
FormLinks.template = '<fieldset class="link">' +
                     '  <input id="news_links_attributes_{i}_title" name="news[links_attributes][{i}][title]" size="30" type="text" /> ' +
                     '  <input id="news_links_attributes_{i}_url" name="news[links_attributes][{i}][url]" size="30" type="text" /> ' +
                     '  <input id="news_links_attributes_{i}_lang" name="news[links_attributes][{i}][lang]" size="30" type="text" /> ' +
                     '</fieldset>';
FormLinks.create = function(div) {
    var links = div.children('.link');
    FormLinks.counter = links.length;
    links.each(function() { FormLinks.bind_link(this); });
    div.append('<fieldset><button type="button" id="add-link">Ajouter un lien</button></fieldset>');
    $('#add-link').click(function() { FormLinks.add_link(div); });
};
FormLinks.bind_link = function(link) {
    var link = $(link);
    link.append('<button type="button" class="remove">Supprimer ce lien</button>');
    link.children('.remove').click(function() { FormLinks.remove_link(link); });
};
FormLinks.add_link = function(div) {
    var last_link = div.children('.link:last');
    last_link.after($.nano(FormLinks.template, {i: FormLinks.counter}));
    FormLinks.bind_link(last_link.next());
    FormLinks.counter++;
};
FormLinks.remove_link = function(link) {
    link.remove();
};

/* Show the toolbar */
if ($('body').hasClass('logged')) {
    if ($('#comments').length > 0) Toolbar.create($('#comments .new-comment'), 'Nouveaux commentaires');
    if ($('#contents').length > 0) Toolbar.create($('#contents .new-content'), 'Contenus pas encore visités');
}

/* Fold/unfold comments */
Folding.create(Toolbar.threshold);

/* Create the button for adding/removing links */
if ($('#form-links')) {
    FormLinks.create($('#form-links'));
}

