_       = require('lodash')
path    = require('path')
faker   = require('faker')
yaml    = require('yaml-front-matter')
Promise = require('bluebird')
fs = Promise.promisifyAll(require('fs-extra'))

picCategories = ['people', 'city', 'fashion', 'nature', 'nightlife', 'transport']

module.exports = (opts = {}) ->
  opts.root = opts.root || path.join(__dirname, '..', 'data/posts/')
  opts.threshold = opts.threshold || 1000
  categories = ['classic', 'independent', 'avantgarde']
  tags = _.range(25).reduce (memo, index) ->
    memo.push(faker.random.bs_buzz())
    memo
  , []
  tags = _.uniq tags

  randomDate = (start, end) ->
    new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()))

  fs.readFileAsync path.join(__dirname, '..', 'movies.txt'), 'utf8'
    .then (data) ->
      Promise.all data.split("\n").slice(0, opts.threshold).map (movie, index) ->
        data =
          title: movie
          slug: movie.toLowerCase().replace(/\s+/g, '-').replace(/[^-\w]/g, '')
          date: randomDate(new Date(2005, 0, 1), new Date())
          category: _.sample categories
          cover: "http://lorempixel.com/g/640/480/#{_.sample(picCategories)}/#{_.random(1, 10)}"
          tags: _.sample tags, _.random(2,5)

        fs.outputFileAsync path.join(opts.root, data.slug + '.md'), "---\n#{yaml.safeDump(data)}---\n" + _.reduce _.range(3,10), (memo, index) ->
          memo += faker.Lorem.paragraph(_.random(2,5)) + '.\n\n'
          memo
