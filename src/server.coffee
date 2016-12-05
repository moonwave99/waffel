express = require 'express'

module.exports = class Server
  constructor: (opts) ->
    @options = opts
    @started = false
    @app = express()

  start: =>
    if @started then return
    @app.use express.static @options.path, @options
    new Promise (resolve, reject) =>
      @app.listen @options.port, =>
        @started = true
        resolve @
  stop: =>
    @app.close()
    @started = false
