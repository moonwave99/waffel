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
    gh_pages:
      optimize: true
      sourcemaps: false
      paths:
        public: 'dist'