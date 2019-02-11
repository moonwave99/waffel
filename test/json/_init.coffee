Waffel  = require '../../src/index'
Promise = require 'bluebird'
path    = require 'path'
fs      = require 'fs-extra'

config_json = global.config_json =
  silent:             true
  languages:          global.languages
  defaultLanguage:    global.languages[0]
  root:               path.join __dirname, '..', 'fixtures'
  dataFolder:         'data_json'
  viewFolder:         'views'
  staticFolder:       'assets'
  localesFolder:      'locales'
  destinationFolder:  '../output/public_json'
  structureFile:      'site_default.yml'

wfl_json = global.wfl_json = new Waffel global.config_json

before (done) ->
  fs.removeSync path.join config_json.root, config_json.destinationFolder
  wfl_json.on 'generation:complete', done
  wfl_json.init().then ->
    wfl_json.generate()
