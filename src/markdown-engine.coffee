_       = require 'lodash'
marked  = require 'marked'

module.exports = class MarkdownEngine
  defaults:
    gfm:          true
    tables:       true
    smartLists:   true
    smartypants:  false
  constructor: (opts) ->
    @options = _.extend {}, @defaults, opts
    marked.setOptions @options
  getRenderer: () ->
    marked
