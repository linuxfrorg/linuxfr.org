$ = window.jQuery

# Popup management: on click on event element, hide / show popup
$(".popup-event").click ->
  # Update active event to the one which were clicked
  event = $(@)
  popupId = event.data("popup-id")
  allEvents = $(".popup-event[data-popup-id=#{popupId}]")
  popup = $("##{popupId}")
  if typeof popup.attr("data-popup-show") is 'undefined'
    popup.attr("data-popup-show", "")
    allEvents.attr("data-popup-shown", "")
  else
    popup.removeAttr("data-popup-show")
    allEvents.removeAttr("data-popup-shown")
  false
