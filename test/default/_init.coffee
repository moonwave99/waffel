Waffel    = require '../../src/index'
generator = require '../../docs/examples/jekyll/lib/generator'
Promise   = require 'bluebird'
path      = require 'path'
fs        = Promise.promisifyAll require 'fs-extra'

config = global.config =
  silent:             true
  domain:             'http://localhost:8000'
  root:               path.join __dirname, '..', 'fixtures'
  dataFolder:         'data'
  viewFolder:         'views'
  staticFolder:       'assets'
  localesFolder:      'locales'
  destinationFolder:  '../public_default'
  structureFile:      'site_default.yml'

wfl = global.wfl = new Waffel global.config

before (done) ->
  postsPath = path.join wfl.options.dataFolder, 'posts'
  fs.removeSync path.join config.root, config.destinationFolder
  fs.removeSync postsPath
  generator { root: postsPath, threshold: 100 }
    .then wfl.init.bind(wfl)
    .then wfl.generate.bind(wfl)
  wfl.on 'generation:complete', done
