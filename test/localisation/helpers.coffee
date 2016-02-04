Promise = require 'bluebird'
cheerio = require 'cheerio'
marked  = require 'marked'
matter  = require 'gray-matter'
path    = require 'path'
fs      = Promise.promisifyAll require 'fs-extra'
_       = require 'lodash'
should  = require 'should'
helpers = require '../../src/helpers'
wfl_localised     = global.wfl_localised
config_localised  = global.config_localised

require 'should-promised'

describe 'Helpers', ->
  describe 'url', ->
    post = {}
    before (done) ->
      post = _.sample wfl_localised.data.posts
      done()

    describe 'of default language', ->
      lan = wfl_localised.options.defaultLanguage
      it "should output home URL", ->
        helpers.url 'home', { language: lan }, wfl
          .should.equal "#{config.domain}/index.html"

      it "should output single blogpost URL", ->
        helpers.url 'blog.single', post[lan], { language: lan, test: true }, wfl
          .should.equal "#{config.domain}/blog/posts/#{post[lan].slug}/index.html"

      it "should output category first page URL", ->
        helpers.url 'blog.categories', post[lan], { page: 1, language: lan }, wfl
          .should.equal "#{config.domain}/blog/category/#{wfl_localised._slugify post[lan].category}/index.html"

      it "should output category further pages URL", ->
        helpers.url 'blog.categories', post[lan], { page: 2, language: lan }, wfl
          .should.equal "#{config.domain}/blog/category/#{wfl_localised._slugify post[lan].category}/page/2/index.html"

    describe 'of other languages', ->
      lan = wfl_localised.options.languages[1]
      it "should output home URL", ->
        helpers.url 'home', {}, { language: lan, localised: true }, wfl
          .should.equal "#{config.domain}/#{lan}/index.html"

      it "should output single blogpost URL", ->
        helpers.url 'blog.single', post[lan], { language: lan, localised: true }, wfl
          .should.equal "#{config.domain}/#{lan}/blog/posts/#{post[lan].slug}/index.html"

      it "should output category first page URL", ->
        helpers.url 'blog.categories', post[lan], { page: 1, language: lan, localised: true }, wfl
          .should.equal "#{config.domain}/#{lan}/blog/category/#{wfl_localised._slugify post[lan].category}/index.html"

      it "should output category further pages URL", ->
        helpers.url 'blog.categories', post[lan], { page: 2, language: lan, localised: true }, wfl
          .should.equal "#{config.domain}/#{lan}/blog/category/#{wfl_localised._slugify post[lan].category}/page/2/index.html"
