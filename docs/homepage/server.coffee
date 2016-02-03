Waffel    = require '../../src/index'
pushserve = require 'pushserve'
_         = require 'lodash'

exports.startServer = (port, path, callback) ->
  wfl = new Waffel
    domain: "http://localhost:#{port}"
    watch:  true

  wfl.init().then ->
    wfl.generate().then callback pushserve port: port, path: path
