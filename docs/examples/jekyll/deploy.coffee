_         = require 'lodash'
Waffel    = require '../../../src/index'
Promise   = require 'bluebird'
generator = require './lib/generator'
shell     = require 'shelljs'

module.exports = (options) ->
  new Promise (resolve, reject) ->
    shell.cd __dirname
    shell.exec "npm run clean"    
    generator().then ->
      opts = _.extend { root: __dirname }, options
      wfl = new Waffel opts
      wfl.init().then ->
        wfl.generate()
        resolve wfl
