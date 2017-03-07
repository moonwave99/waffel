_       = require 'lodash'
should  = require 'should'
Promise = require 'bluebird'
needle  = Promise.promisifyAll require 'needle'
wfl_server_ugly     = global.wfl_server_ugly
config_server_ugly  = global.config_server_ugly

require 'should-promised'

baseURL = "http://localhost:#{config_server_ugly.serverConfig.port}"

describe 'Dev server with uglyUrls', ->
  it "should listen on port #{config_server_ugly.serverConfig.port}", ->
    needle.getAsync(baseURL).then (response) ->
      should( response.statusCode ).be.exactly 200
  it "should serve data from subfolders", ->
    needle.getAsync("#{baseURL}/about").then (response) ->
      should( response.statusCode ).be.exactly 200
