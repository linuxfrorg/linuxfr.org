$ = window.jQuery

# Tabs management: on click hide data from all other sibling tabs
$(".tab").click ->
  # Update active tab to the one which were clicked
  tab = $(@)
  tab.attr("data-show-content", true)
  tab.siblings().removeAttr("data-show-content")
  # Show active content linked to the newly activated tab
  content = $("#" + $(@).data("tab-content-id"))
  content.attr("data-show-content", true)
  content.siblings().removeAttr("data-show-content")
  false
