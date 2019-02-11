Waffel  = require '../../../src/index'
Promise = require 'bluebird'
path    = require 'path'
fs      = require 'fs-extra'

destinationFolder = '../output/public_server_ugly'
absoluteDestinationFolder = path.join __dirname, '..', destinationFolder

config_server_ugly = global.config_server_ugly =
  silent:             true
  root:               path.join __dirname, '../../fixtures'
  dataFolder:         'data'
  viewFolder:         'views'
  staticFolder:       'assets'
  destinationFolder:  destinationFolder
  structureFile:      'site_default.yml'
  server:             true
  uglyUrls:           true
  displayExt:         false
  serverConfig:
    port:       4322
    path:       absoluteDestinationFolder
    indexPath:  "#{absoluteDestinationFolder}/404.html",

wfl_server_ugly = global.wfl_server_ugly = new Waffel global.config_server_ugly

before (done) ->
  fs.removeSync path.join config_server_ugly.root, config_server_ugly.destinationFolder
  wfl_server_ugly.on 'server:start', -> done()
  wfl_server_ugly.init().then ->
    wfl_server_ugly.generate()
