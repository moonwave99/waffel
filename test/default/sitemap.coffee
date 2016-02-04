Promise = require 'bluebird'
cheerio = require 'cheerio'
marked  = require 'marked'
matter  = require 'gray-matter'
path    = require 'path'
fs      = Promise.promisifyAll require 'fs-extra'
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
  rx = /\/index.html$/
  before (done) ->
    fs.readFileAsync sitemapPath, 'utf8'
      .then (content) ->
        sitemapContent = parser(content).root.children.map (x) -> x.children[0].content
        done()
      .catch(done)
  it 'should contain home page', ->
    url = helpers.url('home', wfl).replace /\/index.html$/, ''
    (sitemapContent.indexOf(url) > -1)
      .should.be.exactly true

  it 'should contain about page', ->
    url = helpers.url('about', wfl).replace /\/index.html$/, ''
    (sitemapContent.indexOf(url) > -1)
      .should.be.exactly true

  it 'should contain blog pages', ->
    pagesCount = Math.ceil _.size(wfl.data.posts) / wfl.options.defaultPagination
    pagesFound = 0
    _.range(1, pagesCount+1).forEach (i) ->
      url = helpers.url('blog.index', {}, { page: i }, wfl).replace rx, ''
      pagesFound += (sitemapContent.indexOf(url) > -1)

    pagesFound.should.equal pagesCount

  it 'should contain single blog posts pages', ->
    pagesFound = 0
    _.forEach wfl.data.posts, (post) ->
      url = helpers.url('blog.single', post, wfl).replace rx, ''
      pagesFound += (sitemapContent.indexOf(url) > -1)

    pagesFound.should.equal _.size wfl.data.posts
