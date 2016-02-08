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

destinationFolderForLanguage = (page, language = '') ->
  path.join wfl_localised.options.destinationFolder, language, page.pages.single.url.split('/').filter( (x) -> x.indexOf(':') == -1 ).join('/')

describe 'Localised output structure', ->
  describe 'of blog:', ->
    blogPage    = wfl_localised.structure.blog
    dataFolder  = path.join wfl_localised.options.dataFolder, blogPage.collection
    languages   = _.without wfl_localised.options.languages, wfl_localised.options.defaultLanguage
    contents    = {}

    before (done) ->
      Promise.all wfl_localised.options.languages.map (l) ->
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

    it 'should generate content for default language', ->
      destinationFolder = destinationFolderForLanguage blogPage
      files = glob.sync "**/index#{wfl_localised.options.outputExt}", cwd: destinationFolder
      files.length.should.equal contents[wfl_localised.options.defaultLanguage].length

    it 'should not prepend language slug portion to default language', ->
      destinationFolder = destinationFolderForLanguage blogPage, wfl_localised.options.defaultLanguage
      dirExists = false
      try
        fs.accessSync destinationFolder, fs.F_OK
        dirExists = true
      catch e then dirExists = false
      dirExists.should.equal false

    it 'should generate content for other languages, prepending ISO language slug portion to paths', ->
      Promise.all languages.map (l) ->
        destinationFolder = destinationFolderForLanguage blogPage, l
        files = glob.sync "**/index#{wfl_localised.options.outputExt}", cwd: destinationFolder
        if files.length == contents[l].length
          Promise.resolve destinationFolder
        else
          Promise.reject destinationFolder
      .then (paths) ->
        paths.length.should.equal languages.length
