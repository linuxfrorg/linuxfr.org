$(".markItUp").markItUp(markItUpSettings);

$("a.hit-counter").each(function(n,link) {
    link.href = "/redirect/" + link.getAttribute('data-hit');
});

/* DLFP Toolbar */
var Toolbar = {};
Toolbar.comments    = $(".new-comment");
Toolbar.nb_comments = Toolbar.comments.size();
Toolbar.current     = 0;
Toolbar.next_comment = function() {
    this.current++;
    if (this.current > this.nb_comments) this.current -= this.nb_comments;
    this.go_to_current();
};
Toolbar.prev_comment = function() {
    this.current--;
    if (this.current <= 0) this.current += this.nb_comments;
    this.go_to_current();
};
Toolbar.go_to_current = function() {
    if (this.nb_comments == 0) return ;
    var comment = this.comments[this.current - 1];
    $(document).scrollTop($(comment).offset().top);
	$('#current-comment').text(Toolbar.current);
};

/* Show the toolbar */
$('body').append('<div id="toolbar"><span>Nouveaux commentaires : <span id="current-comment">' +
		Toolbar.current + '</span> / ' + Toolbar.nb_comments +
		' <a href="#" accesskey="<" class="prev">&lt;</a> | ' +
		' <a href="#" accesskey=">" class="next">&gt;</a>' +
		'</span></div>');

$('#toolbar .prev').click(function() {
    Toolbar.prev_comment();
	return false;
});
$('#toolbar .next').click(function() {
    Toolbar.next_comment();
	return false;
});

/* Use the '<' and '>' to navigate in the new comments */
$(document).keypress(function(e) {
    if ($(e.target).is("input")) return ;
    if (e.which == 60) {
        Toolbar.prev_comment();
		return false;
    }
    if (e.which == 62) {
        Toolbar.next_comment();
		return false;
    }
});

