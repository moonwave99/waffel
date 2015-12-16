path    = require 'path'
should  = require 'should'
wfl     = global.wfl
config  = global.config

require 'should-promised'

describe 'Instantiate Waffel', ->
  it 'should set locations', ->
    should(wfl.options.root).be.equal config.root

    ['dataFolder', 'viewFolder', 'staticFolder', 'localesFolder', 'destinationFolder', 'structureFile'].forEach (folder) ->
      should(wfl.options[folder]).be.equal path.join config.root, config[folder]
