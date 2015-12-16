Waffel  = require '../../src/index'
Promise = require 'bluebird'
path    = require 'path'
fs      = Promise.promisifyAll require 'fs-extra'

config_uglyUrls = global.config_uglyUrls =
  silent:             true
  uglyUrls:           true
  root:               path.join __dirname, '..', 'fixtures'
  dataFolder:         'data'
  viewFolder:         'views'
  staticFolder:       'assets'
  localesFolder:      'locales'
  destinationFolder:  '../public_uglyUrls'
  structureFile:      'site_default.yml'

wfl_uglyUrls = global.wfl_uglyUrls = new Waffel global.config_uglyUrls

before (done) ->
  fs.removeSync path.join config_uglyUrls.root, config_uglyUrls.destinationFolder
  wfl_uglyUrls.on 'generation:complete', done
  wfl_uglyUrls.init().then ->
    wfl_uglyUrls.generate()
