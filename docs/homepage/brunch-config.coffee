Waffel = require 'waffel'

exports.config =
  files:
    javascripts:
      joinTo:
        'js/app.js': /^app/
        'js/vendor.js': /^(vendor|bower_components|app)/

    stylesheets:
      joinTo:
        'css/app.css': /^(vendor|bower_components|app)/

    templates:
      joinTo: 'js/app.js'        
        
  server:
    path: 'server.coffee'
          
  conventions:
    assets: /(assets|vendor\/assets|font)/
    
  plugins:            
    autoReload:
      enabled:
        js: on
        css: on
        assets: off
        
  overrides:
    gh_pages:
      optimize: true
      sourcemaps: false
      paths:
        public: 'dist'
        
      onCompile: (generatedFiles) ->
        wfl = new Waffel     
          domain:             'http://moonwave99.github.io/waffel'
          destinationFolder:  'dist'
          uglyUrls:           true

        wfl.init().then ->
          wfl.generate()