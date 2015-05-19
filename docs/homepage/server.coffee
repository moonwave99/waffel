Waffel = require 'waffel'
pushserve = require 'pushserve'
_ = require 'underscore'

exports.startServer = (port, path, callback) ->        
  wfl = new Waffel
    domain:           "http://localhost:#{port}"
    
  wfl.init().then ->
    wfl.generate().then callback pushserve port: port, path: path