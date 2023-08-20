/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const $ = window.jQuery;

// Tabs management: on click hide data from all other sibling tabs
$(".tab").click(function() {
  // Update active tab to the one which were clicked
  const tab = $(this);
  tab.attr("data-show-content", true);
  tab.siblings().removeAttr("data-show-content");
  // Show active content linked to the newly activated tab
  const content = $("#" + $(this).data("tab-content-id"));
  content.attr("data-show-content", true);
  content.siblings().removeAttr("data-show-content");
  return false;
});
