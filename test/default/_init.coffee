Waffel    = require '../../src/index'
generator = require '../../docs/examples/jekyll/lib/generator'
Promise   = require 'bluebird'
path      = require 'path'
fs        = require 'fs-extra'

postNumber = 51
languages = global.languages = ['en', 'it']

config = global.config =
  silent:             true
  domain:             'http://localhost:8000'
  root:               path.join __dirname, '..', 'fixtures'
  dataFolder:         'data'
  viewFolder:         'views'
  staticFolder:       'assets'
  localesFolder:      'locales'
  destinationFolder:  '../output/public_default'
  structureFile:      'site_default.yml'
  config:
    env:  'test'

wfl = global.wfl = new Waffel global.config

before (done) ->
  postsPath = path.join wfl.options.dataFolder, 'posts'
  localisedRoot = path.join config.root, 'data_localised/posts'
  [
    path.join config.root, config.destinationFolder
    postsPath
    localisedRoot
  ].map (x) -> fs.removeSync x
  generator { root: postsPath, threshold: postNumber }
    .then ->
      fs.ensureDirSync localisedRoot
      Promise.all languages.map (x) -> fs.copy postsPath, path.join localisedRoot, x
    .then wfl.init.bind(wfl)
    .then wfl.generate.bind(wfl)
  wfl.on 'generation:complete', done
