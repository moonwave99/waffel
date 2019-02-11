Waffel  = require '../../../src/index'
Promise = require 'bluebird'
path    = require 'path'
fs      = require 'fs-extra'

destinationFolder = '../output/public_server'
absoluteDestinationFolder = path.join __dirname, '..', destinationFolder

config_server = global.config_server =
  silent:             true
  root:               path.join __dirname, '../../fixtures'
  dataFolder:         'data'
  viewFolder:         'views'
  staticFolder:       'assets'
  destinationFolder:  destinationFolder
  structureFile:      'site_default.yml'
  server:             true
  serverConfig:
    port:       4321
    path:       absoluteDestinationFolder
    indexPath:  "#{absoluteDestinationFolder}/404.html",

wfl_server = global.wfl_server = new Waffel global.config_server

before (done) ->
  fs.removeSync path.join config_server.root, config_server.destinationFolder
  wfl_server.on 'server:start', -> done()
  wfl_server.init().then ->
    wfl_server.generate()
