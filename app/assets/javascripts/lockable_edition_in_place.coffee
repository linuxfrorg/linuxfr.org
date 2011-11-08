(($) ->

  $.fn.lockableEditionInPlace = ->
    $(this).bind("in_place:form", ->
      self = $(@)
      self.data cancel: self.find(".cancel").data("url")
      self.data token:  self.find('input[name="authenticity_token"]').serialize()
    ).bind("in_place:reset", ->
      self = $(@)
      $.ajax url: self.data("cancel"), type: "post", data: self.data("token")
    ).bind("in_place:cant_edit", (event, xhr) ->
      $.noticeAdd text: xhr.responseText
    ).editionInPlace("button.edit")

) window.jQuery
