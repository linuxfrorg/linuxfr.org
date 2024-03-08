$ = window.jQuery;

// Popup management: on click on event element, hide / show popup
$(".popup-event").click(function() {
  // Update active event to the one which were clicked
  const event = $(this);
  const popupId = event.data("popup-id");
  const allEvents = $(`.popup-event[data-popup-id=${popupId}]`);
  const popup = $(`#${popupId}`);
  const showPopup = typeof popup.attr("data-popup-show") === "undefined";
  // Update popup status and advertise all popup event togglers
  if (showPopup) {
    popup.attr("data-popup-show", "");
    allEvents.attr("data-popup-shown", "");
  } else {
    popup.removeAttr("data-popup-show");
    allEvents.removeAttr("data-popup-shown");
  }
  // Give new popup display status to all listeners
  const listners = popup.data("popup-listner-ids");

  for (var listner of listners.split(" ")) {
    var listnerElement = $(`#${listner}`);
    if (showPopup) {
      listnerElement.attr(`data-popup-${popupId}-shown`, "");
    } else {
      listnerElement.removeAttr(`data-popup-${popupId}-shown`, "");
    }
  }
});
