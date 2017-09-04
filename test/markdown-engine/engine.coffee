MarkdownIt = require 'markdown-it'

module.exports = class Engine
  constructor: (opts) ->
    @md = new MarkdownIt opts
  getRenderer: () ->
    @md.render.bind @md
