Waffel  = require '../../src/index'
Engine  = require './engine'
Promise = require 'bluebird'
path    = require 'path'
fs      = Promise.promisifyAll require 'fs-extra'

destinationFolder = '../output/public_markdown-engine'
absoluteDestinationFolder = path.join __dirname, '..', destinationFolder

config_markdownEngine = global.config_markdownEngine =
  silent:             true
  root:               path.join __dirname, '../fixtures'
  dataFolder:         'data'
  viewFolder:         'views'
  staticFolder:       'assets'
  destinationFolder:  destinationFolder
  structureFile:      'site_default.yml'
  markdownEngine:     new Engine()

wfl_markdownEngine = global.wfl_markdownEngine = new Waffel global.config_markdownEngine

before (done) ->
  fs.removeSync path.join config_markdownEngine.root, config_markdownEngine.destinationFolder
  wfl_markdownEngine.on 'generation:complete', done
  wfl_markdownEngine.init().then ->
    wfl_markdownEngine.generate()
