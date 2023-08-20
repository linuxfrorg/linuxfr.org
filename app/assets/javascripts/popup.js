/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const $ = window.jQuery;

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
  return (() => {
    const result = [];
    for (var listner of Array.from(listners.split(" "))) {
      var listnerElement = $(`#${listner}`);
      if (showPopup) {
        result.push(listnerElement.attr(`data-popup-${popupId}-shown`, ""));
      } else {
        result.push(
          listnerElement.removeAttr(`data-popup-${popupId}-shown`, "")
        );
      }
    }
    return result;
  })();
});
