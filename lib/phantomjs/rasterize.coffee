page = require('webpage').create()
system = require 'system'

if system.args.length != 5
  console.log 'Usage: phantomjs rasterize.coffee URL filename cookie_name cookie_value'
  phantom.exit 1
else
  address = system.args[1]
  output = system.args[2]
  page.viewportSize = { width: 1024, height: 768 }
  phantom.addCookie
    name: system.args[3]
    value: system.args[4]
    domain: 'dlfp.lo'
    path: '/'
    httpOnly: true
    secure: false
    expires: (new Date()).getTime() + (1000 * 60 * 60)
  page.open address, (status) ->
    if status isnt 'success'
      console.log 'Unable to load the address!'
      phantom.exit()
    else
      window.setTimeout (-> page.render output; phantom.exit()), 200
