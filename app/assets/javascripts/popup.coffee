$ = window.jQuery

# Popup management: on click on event element, hide / show popup
$(".popup-event").click ->
  # Update active event to the one which were clicked
  event = $(@)
  popupId = event.data("popup-id")
  allEvents = $(".popup-event[data-popup-id=#{popupId}]")
  popup = $("##{popupId}")
  showPopup = (typeof popup.attr("data-popup-show") is 'undefined')
  # Update popup status and advertise all popup event togglers
  if showPopup
    popup.attr("data-popup-show", "")
    allEvents.attr("data-popup-shown", "")
  else
    popup.removeAttr("data-popup-show")
    allEvents.removeAttr("data-popup-shown")
  # Give new popup display status to all listeners
  listners = popup.data("popup-listner-ids")
  for listner in listners.split(" ")
    listnerElement = $("##{listner}")
    if showPopup
      listnerElement.attr("data-popup-#{popupId}-shown", "")
    else
      listnerElement.removeAttr("data-popup-#{popupId}-shown", "")
