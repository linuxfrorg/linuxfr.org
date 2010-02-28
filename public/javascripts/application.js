$(".markItUp").markItUp(markItUpSettings);

$("a.hit-counter").each(function() {
    this.href = "/redirect/" + $(this).attr('data-hit');
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

/* Create the button for adding/removing links */
if ($('#form-links')) {
    FormLinks.create($('#form-links'));
}

/* Show the toolbar */
if ($('body').hasClass('logged')) {
    if ($('#comments').length > 0) $('#comments .new-comment').toolbar('Nouveaux commentaires', {folding: '#comments .comment'});
    if ($('#contents').length > 0) $('#contents .new-content').toolbar('Contenus pas encore visités');
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

