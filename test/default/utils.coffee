path    = require 'path'
should  = require 'should'
utils   = require '../../src/utils'

require 'should-promised'

describe 'Utils', ->
  describe 'relativisePath', ->
    it 'should return the path relative to given basePath', ->
      basePath = '/usr/bin'
      filePath = '/usr/bin/foo/bar'
      relativePath = utils.relativisePath filePath, basePath
      relativePath.should.equal "/foo/bar"
