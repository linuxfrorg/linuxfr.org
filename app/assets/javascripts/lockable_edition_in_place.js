$ = window.jQuery;

$.fn.lockableEditionInPlace = function() {
  return $(this)
    .on("in_place:form", function() {
      const self = $(this);
      self.data({ cancel: self.find(".cancel").data("url") });
      self.data({
        token: self.find('input[name="authenticity_token"]').serialize()
      });
    })
    .on("in_place:reset", function() {
      const self = $(this);
      $.ajax({
        url: self.data("cancel"),
        type: "post",
        data: self.data("token")
      });
    })
    .on("in_place:cant_edit", (event, xhr) =>
      $.noticeAdd({ text: xhr.responseText })
    )
    .editionInPlace("button.edit");
};
