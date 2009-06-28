$(".markItUp").markItUp(markItUpSettings);

$("a.hit-counter").each(function(n,link) {
    link.href = "/redirect/" + link.getAttribute('data-hit');
});

/* DLFP Toolbar */
var Toolbar = {};
Toolbar.items     = [];
Toolbar.nb_items  = 0;
Toolbar.current   = 0;
Toolbar.create = function(items, txt) {
    Toolbar.items    = items;
    Toolbar.nb_items = items.length;
    $('body').append('<div id="toolbar"><span>' + txt + ' : ' +
            '<span id="toolbar-current-item">' + Toolbar.current + '</span> / ' +
            '<span id="toolbar-nb-items">' + Toolbar.nb_items + '</span> ' +
            '<a href="#" accesskey="<" class="prev">&lt;</a> | ' +
            '<a href="#" accesskey=">" class="next">&gt;</a>' +
            '</span></div>');
    $('#toolbar .prev').click(function() { return Toolbar.prev_item(); });
    $('#toolbar .next').click(function() { return Toolbar.next_item(); });
    /* Use the '<' and '>' to navigate in the items */
    $(document).keypress(function(e) {
        if ($(e.target).is("input")) return ;
        if (e.which == 60) return Toolbar.prev_item();
        if (e.which == 62) return Toolbar.next_item();
    });
};
Toolbar.next_item = function() {
    this.current++;
    if (this.current > this.nb_items) this.current -= this.nb_items;
    return this.go_to_current();
};
Toolbar.prev_item = function() {
    this.current--;
    if (this.current <= 0) this.current += this.nb_items;
    return this.go_to_current();
};
Toolbar.go_to_current = function() {
    if (this.nb_items == 0) return ;
    var item = this.items[this.current - 1];
    $(document).scrollTop($(item).offset().top);
    $('#toolbar-current-item').text(Toolbar.current);
    return false;
};

/* Show the toolbar */
if ($('body').hasClass('logged')) {
    if ($('#comments').length > 0) Toolbar.create($('#comments .new-comment'), 'Nouveaux commentaires');
    if ($('#contents').length > 0) Toolbar.create($('#contents .new-content'), 'Contenus pas encore visités');
}

