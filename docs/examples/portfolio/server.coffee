Waffel    = require 'waffel'
filters   = require './lib/filters'
helpers   = require './lib/helpers'
thumbs    = require './lib/thumbs'

exports.startServer = (port, path, callback) ->        
  pattern = "#{__dirname}/data/images/pictures/*"
  thumbPath = "#{__dirname}/app/assets/images/pictures/thumbs"
  thumbRelativePath = 'images/pictures/thumbs'
  thumbnailWidth = 600
  wfl = new Waffel
    domain:           "http://localhost:#{port}"
    uglyUrls:         true
    filters:          filters         
    helpers:          helpers    
    server:           true
    serverConfig:
      port:       port
      path:       path
      indexPath:  "#{path}/404.html"    
  
  thumbs pattern, thumbPath, thumbRelativePath, thumbnailWidth, process.cwd(), (imgInfo) ->
    wfl.on 'server:start', callback    
    wfl.init().then ->
      console.log imgInfo
      wfl.generate
        data:
          imgInfo:  imgInfo