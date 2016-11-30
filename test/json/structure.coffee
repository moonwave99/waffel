_       = require 'lodash'
Promise = require 'bluebird'
cheerio = require 'cheerio'
fs      = require 'fs-extra'
path    = require 'path'
should  = require 'should'
matter  = require 'gray-matter'
glob    = require 'globby'
wfl_json     = global.wfl_json
config_json  = global.config_json

require 'should-promised'

outputFolder = path.join config_json.root

describe 'JSON output structure', ->
  it 'should contain about page', ->
    pathName = path.join wfl_json.options.destinationFolder, 'about', "index#{wfl_json.options.outputExt}"
    should( fs.existsSync pathName ).be.exactly true
