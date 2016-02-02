_       = require 'lodash'
Promise = require 'bluebird'
cheerio = require 'cheerio'
fs      = require 'fs-extra'
path    = require 'path'
should  = require 'should'
matter  = require 'gray-matter'
glob    = require 'globby'
wfl_localised     = global.wfl_localised
config_localised  = global.config_localised

require 'should-promised'

outputFolder = path.join config_localised.root

describe 'Localised output structure', ->
  describe 'of blog:', ->
    blogPage    = wfl_localised.structure.blog
    dataFolder  = path.join wfl_localised.options.dataFolder, blogPage.collection
    languages   = _.without wfl_localised.options.languages, wfl_localised.options.defaultLanguage
    contents    = {}

    before (done) ->
      Promise.all languages.map (l) ->
        _path = path.join dataFolder, l
        new Promise (resolve, reject) ->
          glob "*.md", { cwd: _path }, (err, files) ->
            if err then return reject _path
            contents[l] = files.map (x) -> matter.read(path.join(_path, x), delims: wfl.options.frontmatter.delims)
            resolve _path
      .then ->
        done()
      .catch (e) ->
        done()

    it 'should generate content for all languages', ->
      Promise.all languages.map (l) ->
        destinationFolder = path.join wfl_localised.options.destinationFolder, l, blogPage.pages.single.url.split('/').filter( (x) -> x.indexOf(':') == -1 ).join('/')
        files = glob.sync "**/index.html", cwd: destinationFolder
        if files.length == contents[l].length
          Promise.resolve destinationFolder
        else
          Promise.reject destinationFolder
      .then (paths) ->
        paths.length.should.equal languages.length
