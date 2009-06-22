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
    var comment = this.comments[this.current - 1];
    $(document).scrollTop($(comment).offset().top);
};

/* Use the '<' and '>' to navigate in the new comments */
$(document).keypress(function(e) {
    if ($(e.target).is("input")) return ;
    if (e.which == 60) {
        Toolbar.prev_comment();
        e.preventDefault();
    }
    if (e.which == 62) {
        Toolbar.next_comment();
        e.preventDefault();
    }
});

