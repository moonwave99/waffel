fs      = require 'fs-extra'
path    = require 'path'
should  = require 'should'
wfl     = global.wfl
config  = global.config

require 'should-promised'

outputFolder = path.join config.root

describe 'Output structure', ->
  it 'should contain homepage', ->
    pathName = path.join wfl.options.destinationFolder, "index#{wfl.options.outputExt}"
    should( fs.existsSync pathName ).be.exactly true

  it 'should contain about page', ->
    pathName = path.join wfl.options.destinationFolder, 'about', "index#{wfl.options.outputExt}"
    should( fs.existsSync pathName ).be.exactly true

  it 'should contain 404 page', ->
    pathName = path.join wfl.options.destinationFolder, '404', "index#{wfl.options.outputExt}"
    should( fs.existsSync pathName ).be.exactly true

  it 'should contain sitemap', ->
    pathName = path.join wfl.options.destinationFolder, wfl.options.sitemapName
    should( fs.existsSync pathName ).be.exactly true
