/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const $ = window.jQuery;

$.fn.lockableEditionInPlace = function() {
  return $(this)
    .on("in_place:form", function() {
      const self = $(this);
      self.data({ cancel: self.find(".cancel").data("url") });
      return self.data({
        token: self.find('input[name="authenticity_token"]').serialize()
      });
    })
    .on("in_place:reset", function() {
      const self = $(this);
      return $.ajax({
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
