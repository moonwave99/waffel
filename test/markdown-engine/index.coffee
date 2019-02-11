Promise = require 'bluebird'
cheerio = require 'cheerio'
matter  = require 'gray-matter'
path    = require 'path'
fs      = require 'fs-extra'
should  = require 'should'
wfl     = global.wfl_markdownEngine
config  = global.config_markdownEngine

require 'should-promised'

outputFolder = path.join config.root

expectedParagraphs = 3
expectedBlockQuotes = 1
expectedListItems = 3
expectedSignature = 'Your grandma'

describe 'Content Generation with alternative Markdown engine', ->
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

    it "should have #{expectedParagraphs} first level <p>", ->
      $('main > p').length.should.equal expectedParagraphs

    it "should have #{expectedBlockQuotes} <blockquote>", ->
      $('main > blockquote').length.should.equal expectedBlockQuotes

    it "should have a <ul> with #{expectedListItems} <li>", ->
      $('main ul li').length.should.equal expectedListItems

    it "should be signed by your #{expectedSignature}", ->
      $('main p').last().text().should.equal expectedSignature
