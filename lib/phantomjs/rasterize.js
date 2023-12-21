const page = require('webpage').create();
const system = require('system');

if (system.args.length !== 5) {
  console.log('Usage: phantomjs rasterize.js URL filename cookie_name cookie_value');
  phantom.exit(1);
} else {
  const address = system.args[1];
  const output = system.args[2];
  page.viewportSize = { width: 1024, height: 768 };
  phantom.addCookie({
    name: system.args[3],
    value: system.args[4],
    domain: 'dlfp.lo',
    path: '/',
    httpOnly: true,
    secure: false,
    expires: (new Date()).getTime() + (1000 * 60 * 60)
  });
  page.open(address, function(status) {
    if (status !== 'success') {
      console.log('Unable to load the address!');
      phantom.exit();
    } else {
      window.setTimeout(function() {
        page.render(output);
        phantom.exit();
      }, 200);
    }
  });
}
