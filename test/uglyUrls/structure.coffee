fs      = require 'fs-extra'
path    = require 'path'
should  = require 'should'
wfl_uglyUrls     = global.wfl_uglyUrls
config_uglyUrls  = global.config_uglyUrls

require 'should-promised'

outputFolder = path.join config_uglyUrls.root

describe 'Output structure with uglyUrls', ->
  it 'should contain pathName', ->
    pathName = path.join wfl_uglyUrls.options.destinationFolder, "index#{wfl_uglyUrls.options.outputExt}"
    should( fs.existsSync pathName ).be.exactly true

  it 'should contain about page', ->
    pathName = path.join wfl_uglyUrls.options.destinationFolder, "about#{wfl_uglyUrls.options.outputExt}"
    should( fs.existsSync pathName ).be.exactly true

  it 'should contain 404 page', ->
    pathName = path.join wfl_uglyUrls.options.destinationFolder, "404#{wfl_uglyUrls.options.outputExt}"
    should( fs.existsSync pathName ).be.exactly true
