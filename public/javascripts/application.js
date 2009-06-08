$(".markItUp").markItUp(markItUpSettings);

$("a.hit-counter").each(function(n,link) {
    link.href = "/redirect/" + link.getAttribute('data-hit');
});
