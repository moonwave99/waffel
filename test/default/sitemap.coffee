Promise = require 'bluebird'
cheerio = require 'cheerio'
marked  = require 'marked'
matter  = require 'gray-matter'
path    = require 'path'
fs      = Promise.promisifyAll require 'fs-extra'
parser  = require 'xml-parser'
should  = require 'should'
helpers = require '../../src/helpers'
wfl     = global.wfl
config  = global.config

require 'should-promised'

outputFolder = path.join config.root

describe 'Sitemap', ->
  sitemapPath = path.join wfl.options.destinationFolder, wfl.options.sitemapName
  sitemapContent = {}
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
