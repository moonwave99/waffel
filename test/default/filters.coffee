Promise = require 'bluebird'
cheerio = require 'cheerio'
marked  = require 'marked'
matter  = require 'gray-matter'
path    = require 'path'
fs      = Promise.promisifyAll require 'fs-extra'
should  = require 'should'
wfl     = global.wfl
config  = global.config

require 'should-promised'

describe 'Filters', ->
  describe 'excerpt', ->
    excerptFilter = wfl.filters.excerpt
    it 'should trim output after provided threshold', ->
      input = "Sweet thing I watch you, HEY HEY HEY!"
      output = excerptFilter input, 23
      output.should.equal "Sweet thing I watch…"
      true
    it 'should strip HTML tags', ->
      output = excerptFilter '**hello** _world_'
      output.should.equal 'hello world'
