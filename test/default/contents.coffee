Promise = require 'bluebird'
cheerio = require 'cheerio'
marked  = require 'marked'
matter  = require 'gray-matter'
path    = require 'path'
fs      = require 'fs-extra'
should  = require 'should'
wfl     = global.wfl
config  = global.config

require 'should-promised'

outputFolder = path.join config.root

describe 'Content Generation', ->
  describe 'of homepage:', ->
    homepage = path.join wfl.options.destinationFolder, "index#{wfl.options.outputExt}"
    $ = null
    before (done) ->
      fs.readFile homepage, 'utf8'
        .then (content) ->
          $ = cheerio.load content
          done()
        .catch(done)

    it 'should have <head> title equal to configuration title', ->
      $('title').first().text().should.equal wfl.config.title

    it 'should have <h1> title equal to configuration title', ->
      $('h1').first().text().should.equal wfl.config.title

    it 'should have <main> text equal to configuration description', ->
      $('main p').first().text().should.equal wfl.config.description

  describe 'of about page:', ->
    sourcePath    = path.join __dirname, '..', 'fixtures', 'data', 'pages', "about#{wfl.options.dataExt}"
    sourceContent = matter.read sourcePath, delims: wfl.options.frontmatter.delims
    outputPath    = path.join wfl.options.destinationFolder, sourceContent.data.slug, "index#{wfl.options.outputExt}"
    $ = null
    before (done) ->
      fs.readFile(outputPath, 'utf8').then (output)->
        $ = cheerio.load output
        done()
      .catch(done)

    it "should have <head> title like in data/pages/about#{wfl.options.dataExt}", ->
      $('title').first().text().should.equal sourceContent.data.title

    it "should have <h1> title like in data/pages/about#{wfl.options.dataExt}", ->
      $('h1').first().text().should.equal sourceContent.data.title
