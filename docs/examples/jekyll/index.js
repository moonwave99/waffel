var Waffel = require('../../../lib/index')
var generator = require('./lib/generator')

// Generate some data here
generator().then(function(){
  // We do the Waffel stuff here.
  var port = 1337
  var wfl = new Waffel({
    domain:   "http://localhost:" + port,
    uglyUrls: true,
    server:   true,
    serverConfig: {
      port:       port,
      path:       'public',
      indexPath:  'public/404.html'
    }
  })

  wfl.init().then(function(){ wfl.generate() })
})
