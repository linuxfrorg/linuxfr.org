$ = window.jQuery;

class EditionInPlace {
  constructor(el, edit) {
    this.loadForm = this.loadForm.bind(this);
    this.cantEdit = this.cantEdit.bind(this);
    this.showForm = this.showForm.bind(this);
    this.reset = this.reset.bind(this);
    this.submitForm = this.submitForm.bind(this);
    this.error = this.error.bind(this);
    this.success = this.success.bind(this);
    this.el = el;
    this.edit = edit;
    this.url = this.el.data("url") || document.location.pathname + "/modifier";
    this.button().click(this.loadForm);
  }

  button() {
    if (this.edit) {
      return this.el.find(this.edit);
    } else {
      return this.el;
    }
  }

  loadForm() {
    this.button().off("click");
    this.old = this.el.html();
    this.xhr = $.ajax({ url: this.url, type: "get", dataType: "html" })
      .fail(this.cantEdit)
      .done(this.showForm);
    return false;
  }

  cantEdit() {
    this.el.trigger("in_place:cant_edit", this.xhr);
    this.button().click(this.loadForm);
    this.xhr = null;
  }

  showForm() {
    const form = this.el.html(this.xhr.responseText).find("form");
    form.find(".cancel").click(this.reset);
    form.find("textarea, input, select")[0].select();
    form.find(".markItUp").markItUp(window.markItUpSettings);
    form.submit(this.submitForm);
    this.el.trigger("in_place:form", this.xhr);
    this.xhr = null;
  }

  reset(event) {
    this.el.html(this.old);
    this.button().click(this.loadForm);
    this.el.trigger("in_place:reset", event);
    return false;
  }

  submitForm() {
    const form = this.el.find("form");
    const url = form.attr("action");
    const data = form.serialize();
    this.xhr = $.ajax({ url, type: "post", data, dataType: "html" })
      .fail(this.error)
      .done(this.success);
    return false;
  }

  error() {
    try {
      let message;
      const error = this.el.find("ul.error");
      const response = $.parseJSON(this.xhr.responseText);
      const messages = [];
      for (var attribute in response.errors) {
        var errors = response.errors[attribute];
        for (message of errors) {
          messages.push(message);
        }
      }
      if (messages.length === 1) {
        error.text("Erreur : " + messages[0]);
      } else {
        error.text("Erreurs :");
        for (message of messages) {
          error.append($("<li>").append(message));
        }
      }
      error.show();
    } catch (error1) {}
    this.el.trigger("in_place:error", this.xhr);
    this.xhr = null;
  }

  success() {
    this.el = $(this.xhr.responseText).replaceAll(this.el);
    this.button().click(this.loadForm);
    this.el.trigger("in_place:success", this.xhr);
    this.xhr = null;
  }
}

$.fn.editionInPlace = function(edit_selector) {
  return this.each(function() {
    return new EditionInPlace($(this), edit_selector);
  });
};
