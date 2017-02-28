Waffel = require '../../src/index'

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
      sourceMaps: false
      paths:
        public: 'dist'
      hooks:
        onCompile: (generatedFiles) ->
          wfl = new Waffel
            domain:             'https://moonwave99.github.io/waffel'
            destinationFolder:  'dist'

          wfl.init().then ->
            wfl.generate()
