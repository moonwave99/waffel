Waffel    = require 'waffel'
filters   = require './lib/filters'
helpers   = require './lib/helpers'
thumbs    = require './lib/thumbs'

exports.config =
  files:
    javascripts:
      joinTo:
        'js/app.js': /^app/
        'js/vendor.js': /^(vendor|bower_components|app)/

    stylesheets:
      joinTo:
        'css/app.css': /^(vendor|bower_components|app)/
        
  server:
    path: 'server.coffee'
          
  conventions:
    assets: /(assets|vendor\/assets|font)/
    
  plugins:            
    assetsmanager:
      minTimeSpanSeconds: 10
      copyTo:
        '' : ['data/images']    
        
    autoReload:
      enabled:
        js: on
        css: on
        assets: off
        
  overrides:
    production:
      optimize: true
      sourcemaps: false
      paths:
        public: 'production'
        
      onCompile: (generatedFiles) ->
        wfl = new Waffel
          domain:             'http//example.com'
          destinationFolder:  'production'
          uglyUrls:           true
          filters:            filters         
          helpers:            helpers

        wfl.init().then -> wfl.generate()