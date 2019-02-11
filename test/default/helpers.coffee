Promise = require 'bluebird'
cheerio = require 'cheerio'
marked  = require 'marked'
matter  = require 'gray-matter'
path    = require 'path'
_       = require 'lodash'
should  = require 'should'
helpers = require '../../src/helpers'
wfl     = global.wfl
config  = global.config

require 'should-promised'

describe 'Helpers', ->
  post = {}
  before (done) ->
    post = _.sample wfl.data.posts
    done()
  describe 'classes()', ->
    inputClasses =
      classOne: true
      classTwo: false
      classThree: true
    it "should include keys with truthy values", ->
      helpers.classes inputClasses
        .should.equal 'classOne classThree'
    it "should exclude keys with falsey values", ->
      helpers.classes inputClasses
        .indexOf 'classTwo'
        .should.be.exactly -1

  describe 'url()', ->
    it "should output home URL", ->
      helpers.url 'home', wfl
        .should.equal "#{config.domain}/index#{wfl.options.outputExt}"

    it "should output single blogpost URL", ->
      helpers.url 'blog.single', post, {}, wfl
        .should.equal "#{config.domain}/blog/posts/#{post.slug}/index#{wfl.options.outputExt}"

    it "should output category first page URL", ->
      helpers.url 'blog.categories', post, { page: 1 }, wfl
        .should.equal "#{config.domain}/blog/category/#{wfl._slugify post.category}/index#{wfl.options.outputExt}"

    it "should output category further pages URL", ->
      helpers.url 'blog.categories', post, { page: 2 }, wfl
        .should.equal "#{config.domain}/blog/category/#{wfl._slugify post.category}/page/2/index#{wfl.options.outputExt}"

  describe 'loc()', ->
    describe 'without localisation', ->
      lan = wfl.options.defaultLanguage
      it 'should return entity itself', ->
        helpers.loc(post, lan, wfl)
          .should.equal post
