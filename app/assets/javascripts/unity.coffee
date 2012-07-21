# Integration with Unity (Ubuntu)
# See http://developer.ubuntu.com/api/ubuntu-12.04/javascript/index.html

$ = window.jQuery
Unity = null

answers = ->
  $.getJSON "/tableau-de-bord/reponses", (data) ->
    count = data.node_ids.length
    if count > 0
      Unity.Launcher.setCount count
    else
      Unity.Launcher.clearCount()

init = ->
  answers()
  setInterval answers, 60000
  Unity.Launcher.addAction "Proposer un contenu", ->
    window.location.assign "/proposer-un-contenu"

# XXX For a weird reason, we have to wait 1s before external gets the getUnityObject property
setTimeout ->
  return unless window.external && window.external.getUnityObject
  Unity = window.external.getUnityObject(1)
  Unity.init
    name: "LinuxFr.org"
    iconUrl: "http://linuxfr.org/images/linuxfr2_64.png"
    onInit: init
, 1000
