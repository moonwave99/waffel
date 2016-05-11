_       = require 'lodash'
Promise = require 'bluebird'
cheerio = require 'cheerio'
fs      = require 'fs-extra'
path    = require 'path'
should  = require 'should'
matter  = require 'gray-matter'
glob    = require 'globby'
wfl     = global.wfl
config  = global.config

require 'should-promised'

outputFolder = path.join config.root

describe 'Output structure', ->
  it 'should contain homepage', ->
    pathName = path.join wfl.options.destinationFolder, "index#{wfl.options.outputExt}"
    should( fs.existsSync pathName ).be.exactly true

  it 'should contain about page', ->
    pathName = path.join wfl.options.destinationFolder, 'about', "index#{wfl.options.outputExt}"
    should( fs.existsSync pathName ).be.exactly true

  it 'should contain 404 page', ->
    pathName = path.join wfl.options.destinationFolder, '404', "index#{wfl.options.outputExt}"
    should( fs.existsSync pathName ).be.exactly true

  it 'should contain sitemap', ->
    pathName = path.join wfl.options.destinationFolder, wfl.options.sitemapName
    should( fs.existsSync pathName ).be.exactly true

  describe 'of blog:', ->
    blogPage = wfl.structure.blog
    dataFolder = path.join wfl.options.dataFolder, blogPage.collection
    contents = []

    before (done) ->
      glob "*.md", { cwd: dataFolder }, (err, files) ->
        if err then return done()
        contents = files.map (x) -> matter.read(path.join(dataFolder, x), delims: wfl.options.frontmatter.delims)
        done()

    it "should group posts by category", ->
      destinationFolder = path.join wfl.options.destinationFolder, blogPage.pages.categories.url.split('/').filter( (x) -> x.indexOf(':') == -1 ).join('/')
      dataCategories = _(contents).map( (x) -> x.data.category ).uniq().map(wfl._slugify).value().sort()
      generatedCategories = glob.sync '*/', cwd: destinationFolder
        .map (x) -> x.replace '/', ''
        .sort()
      dataCategories.toString().should.equal generatedCategories.toString()

    it "should group posts by tag", ->
      destinationFolder = path.join wfl.options.destinationFolder, blogPage.pages.tags.url.split('/').filter( (x) -> x.indexOf(':') == -1 ).join('/')
      dataTags = _(contents).map( (x) -> x.data.tags ).flatten().uniq().map(wfl._slugify).value().sort()
      generatedTags = glob.sync '*/', cwd: destinationFolder
        .map (x) -> x.replace '/', ''
        .sort()
      dataTags.toString().should.equal generatedTags.toString()

    it "should limit page number", ->
      destinationFolder = path.join wfl.options.destinationFolder, blogPage.pages.feed.url
      glob.sync('*.html', cwd: destinationFolder).length.should.be.exactly 1

    it "should paginate posts", ->
      destinationFolder = path.join wfl.options.destinationFolder, blogPage.pages.index.url
      pageRootFolder = path.join destinationFolder, 'page'
      files = _(
        [path.join destinationFolder, 'index.html'].concat glob.sync('**/index.html', cwd: pageRootFolder ).map (x) -> path.join pageRootFolder, x
      ).sortBy (x) ->
        if pageNum = x.replace(destinationFolder, '').match /\d+/ then +pageNum[0] else 1
      .map (x)->
        fs.readFileAsync x, 'utf8'
          .then (content) ->
            $ = cheerio.load content
      .value()
      Promise.all(files).then (results) ->
        contents.length.should.equal _.reduce results,
          (memo, $) ->
            memo += $('article').length
            memo
          , 0
