//= require push

$ = window.jQuery;

class Redaction {
  constructor(chan) {
    this.onRevision = this.onRevision.bind(this);
    this.onAddLink = this.onAddLink.bind(this);
    this.onUpdateLink = this.onUpdateLink.bind(this);
    this.onAddParagraph = this.onAddParagraph.bind(this);
    this.onUpdateParagraph = this.onUpdateParagraph.bind(this);
    const push = $.push(chan);
    for (var name in this) {
      var fn = this[name];
      if (name.slice(0, 2) === "on") {
        var kind = name
          .replace(/[A-Z]/g, "_$&")
          .toLowerCase()
          .slice(3);
        push.on(kind, fn);
      }
    }
    push.start();
  }

  onSubmit(msg) {
    $.noticeAdd({
      text: `${msg.username} a soumis la dépêche`,
      stay: true
    });
  }

  onPublish(msg) {
    $.noticeAdd({
      text: `La dépêche a été acceptée par ${msg.username}`,
      stay: true
    });
  }

  onRefuse(msg) {
    $.noticeAdd({
      text: `La dépêche a été refusée par ${msg.username}`,
      stay: true
    });
  }

  onRewrite(msg) {
    $.noticeAdd({
      text: `La dépêche a été renvoyée dans l’espace de rédaction par ${
        msg.username
      }`,
      stay: true
    });
  }

  onVote(msg) {
    $.noticeAdd({ text: `${msg.username} a voté ${msg.word}` });
    $("#news_vote").load(`/moderation/news/${msg.news_id}/vote`);
  }

  onUpdate(msg) {
    $("#news_header .title").text(msg.title);
    $("#news_header .topic").text(msg.section.title);
    $("#edition figure.image img").attr({
      src: `/images/sections/${msg.section.id}.png`
    });
  }

  liForRevision(msg) {
    const parts = window.location.pathname.split("/");
    const slug = parts[parts.length - 1];
    return `\
<li><a href="/redaction/news/${slug}/revisions/${msg.version}">
  ${msg.username} : ${msg.message} - ${msg.creationdate}
</a></li>\
`;
  }

  onRevision(msg) {
    $("#news_revisions ul").prepend(this.liForRevision(msg));
    $("#topbar .revision-cell").text(msg.version);
    const atPosition = msg.creationdate.indexOf(":") - 2;
    const finalDate = [
      msg.creationdate.slice(0, atPosition),
      "à ",
      msg.creationdate.slice(atPosition)
    ].join("");
    $("#topbar .revision-date").text("le " + finalDate);
  }

  innerHtmlForLink(msg) {
    return `\
<a href="/redirect/${msg.id}" class="hit_counter">${msg.title}</a> (${
      msg.nb_clicks
    } clic${msg.nb_clicks > 1 ? "s" : ""})\
`;
  }

  htmlForLink(msg) {
    return `\
<li class="link" id="link_${msg.id}" lang="${
      msg.lang
    }" data-url="/redaction/links/${msg.id}/modifier">
  ${this.innerHtmlForLink(msg)}
  <div class="actions">
    <button class="edit">Modifier</button>
  </div>
</li>\
`;
  }

  onAddLink(msg) {
    $("#links").append(this.htmlForLink(msg));
    $(`#link_${msg.id}`).lockableEditionInPlace();
  }

  onUpdateLink(msg) {
    $(`#link_${msg.id}`)
      .html(this.innerHtmlForLink(msg))
      .attr({ lang: msg.lang });
  }

  onRemoveLink(msg) {
    $(`#link_${msg.id}`).remove();
  }

  htmlForPara(msg) {
    return `\
<div id="paragraph_${msg.id}" class="paragraph ${
      msg.part
    }" data-url="/redaction/paragraphs/${msg.id}/modifier">
  ${msg.body}
  <div class="actions">
    <button class="edit">Modifier</button>
  </div>
</div>\
`;
  }

  onAddParagraph(msg) {
    if (msg.after) {
      $(`#paragraph_${msg.after}`).after(this.htmlForPara(msg));
    } else {
      $(`#${msg.part}`).append(this.htmlForPara(msg));
    }
    $(`#paragraph_${msg.id}`).lockableEditionInPlace();
  }

  onUpdateParagraph(msg) {
    $(`#paragraph_${msg.id}`).html(msg.body);
  }

  onRemoveParagraph(msg) {
    $(`#paragraph_${msg.id}`).remove();
  }

  onSecondPartToc(msg) {
    $(".second_part_toc").html(msg.toc);
  }

  onLockParagraph(msg) {
    const editing = $(`\
<img class="editing"
     id="editing_${msg.id}"
     alt="${msg.user.name} est en train de modifier ce paragraphe"
     title="${msg.user.name} est en train de modifier ce paragraphe"
     src="${msg.user.avatar}" />\
`);
    $(`#paragraph_${msg.id} .actions`).prepend(editing);
  }

  onUnlockParagraph(msg) {
    $(`#editing_${msg.id}`).remove();
  }
}

$.fn.redaction = function() {
  return this.each(function() {
    return new Redaction($(this).data("chan"));
  });
};
