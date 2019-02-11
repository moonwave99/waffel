Promise = require 'bluebird'
cheerio = require 'cheerio'
marked  = require 'marked'
matter  = require 'gray-matter'
path    = require 'path'
fs      = require 'fs-extra'
_       = require 'lodash'
parser  = require 'xml-parser'
should  = require 'should'
helpers = require '../../src/helpers'
wfl     = global.wfl
config  = global.config

require 'should-promised'

describe 'Sitemap', ->
  sitemapPath = path.join wfl.options.destinationFolder, wfl.options.sitemapName
  sitemapContent = {}
  rx = ///\/index#{wfl.options.outputExt}$///
  totalPages = 0
  before (done) ->
    fs.readFile sitemapPath, 'utf8'
      .then (content) ->
        sitemapContent = parser(content).root.children.map (x) -> x.children[0].content
        done()
      .catch(done)

  it 'should contain home page', ->
    url = helpers.url('home', wfl).replace rx, ''
    found = (sitemapContent.indexOf(url) > -1)
    if found then totalPages+=1
    found.should.be.exactly true

  it 'should contain about page', ->
    url = helpers.url('about', wfl).replace rx, ''
    found = (sitemapContent.indexOf(url) > -1)
    if found then totalPages+=1
    found.should.be.exactly true

  it 'should contain blog pages', ->
    pagesCount = Math.ceil _.size(wfl.data.posts) / wfl.options.defaultPagination
    pagesFound = 0
    _.range(1, pagesCount+1).forEach (i) ->
      url = helpers.url('blog.index', {}, { page: i }, wfl).replace rx, ''
      pagesFound += (sitemapContent.indexOf(url) > -1)

    totalPages+=pagesFound
    pagesFound.should.equal pagesCount

  it 'should contain single blog posts pages', ->
    pagesCount =  _.size wfl.data.posts
    pagesFound = 0
    _.forEach wfl.data.posts, (post) ->
      url = helpers.url('blog.single', post, wfl).replace rx, ''
      pagesFound += (sitemapContent.indexOf(url) > -1)

    totalPages+=pagesFound
    pagesFound.should.equal pagesCount

  it 'should contain blog category pages', ->
    pagesFound = 0
    pagesCount = 0
    categories = _.reduce wfl.data.posts,
      (memo, item) ->
        memo[item.category] = memo[item.category] || 0
        memo[item.category]++
        memo
      , {}
    _.forEach categories, (count, category) ->
      pagesCount += Math.ceil count / wfl.options.defaultPagination
      _.range(1, count+1).forEach (i) ->
        url = helpers.url('blog.categories', { category: wfl._slugify category }, { page: i }, wfl).replace rx, ''
        pagesFound += (sitemapContent.indexOf(url) > -1)

    totalPages+=pagesFound
    pagesFound.should.equal pagesCount

  it 'should contain blog tag pages', ->
    pagesFound = 0
    pagesCount = 0
    tags = _.reduce wfl.data.posts,
      (memo, item) ->
        item.tags ||= []
        item.tags.forEach (tag) ->
          memo[tag] = memo[tag] || 0
          memo[tag]++
        memo
      , {}
    _.forEach tags, (count, tag) ->
      pagesCount += Math.ceil count / wfl.options.defaultPagination
      _.range(1, count+1).forEach (i) ->
        url = helpers.url('blog.tags', { tag: wfl._slugify tag }, { page: i }, wfl).replace rx, ''
        pagesFound += (sitemapContent.indexOf(url) > -1)

    totalPages+=pagesFound
    pagesFound.should.equal pagesCount

  it 'should contain all generated pages', ->
    totalPages.should.equal sitemapContent.length
