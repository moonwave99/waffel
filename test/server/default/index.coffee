_       = require 'lodash'
should  = require 'should'
Promise = require 'bluebird'
needle  = Promise.promisifyAll require 'needle'
wfl_server     = global.wfl_server
config_server  = global.config_server

require 'should-promised'

baseURL = "http://localhost:#{config_server.serverConfig.port}"

describe 'Dev server', ->
  it "should listen on port #{config_server.serverConfig.port}", ->
    needle.getAsync(baseURL).then (response) ->
      should( response[0].statusCode ).be.exactly 200
  it "should serve data from subfolders", ->
    needle.getAsync("#{baseURL}/about/index.html").then (response) ->
      should( response[0].statusCode ).be.exactly 200
