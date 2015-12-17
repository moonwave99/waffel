Waffel    = require '../../../src/index'
generator = require './lib/generator'

# Generate some data here
generator().then ->
  # We do the Waffel stuff here.
  port = 1337
  wfl = new Waffel
    domain:   "http://localhost:" + port
    uglyUrls: true
    server:   true
    serverConfig:
      port:       port
      path:       'public'
      indexPath:  'public/404.html'

  wfl.init().then ->
    wfl.generate()
