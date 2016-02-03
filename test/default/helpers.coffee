Promise = require 'bluebird'
cheerio = require 'cheerio'
marked  = require 'marked'
matter  = require 'gray-matter'
path    = require 'path'
fs      = Promise.promisifyAll require 'fs-extra'
_       = require 'lodash'
should  = require 'should'
helpers = require '../../src/helpers'
wfl     = global.wfl
config  = global.config

require 'should-promised'

outputFolder = path.join config.root

describe 'Helpers', ->
  describe 'url', ->
    post = {}
    before (done) ->
      post = _.sample wfl.data.posts
      # console.log post
      done()

    it "should output home URL", ->
      helpers.url 'home', wfl
        .should.equal "#{config.domain}/index.html"

    it "should output single blogpost URL", ->
      helpers.url 'blog.single', post, {}, wfl
        .should.equal "#{config.domain}/blog/posts/#{post.slug}/index.html"

    it "should output category first page URL", ->
      helpers.url 'blog.categories', post, { page: 1 }, wfl
        .should.equal "#{config.domain}/blog/category/#{wfl._slugify post.category}/index.html"

    it "should output category further pages URL", ->
      helpers.url 'blog.categories', post, { page: 2 }, wfl
        .should.equal "#{config.domain}/blog/category/#{wfl._slugify post.category}/page/2/index.html"
