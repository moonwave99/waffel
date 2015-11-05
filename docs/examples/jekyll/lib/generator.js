#! /usr/bin/env node

var path = require('path');
var _ = require('lodash')
var faker = require('faker')
var yaml = require('yaml-front-matter')
var Promise = require('bluebird')
var fs = Promise.promisifyAll(require('fs-extra'))

module.exports = function(){
  // We fake some data here.
  var movies = fs.readFileSync(path.join(__dirname, '..', 'movies.txt')).toString().split("\n")
  var categories = ['classic', 'independent', 'avantgarde']
  var tags = _.reduce(_.range(25), function(memo, index){
    memo.push(faker.random.bs_buzz())
    return memo
  }, [])
  tags = _.uniq(tags)

  function randomDate(start, end) {
    return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
  }

  return fs.readFileAsync(path.join(__dirname, '..', 'movies.txt'), 'utf8').then(function(data){
    return Promise.all(data.split("\n").map(function(movie, index){
      var data = {
        title: movie,
        slug: movie.toLowerCase().replace(/\s+/g, '-').replace(/[^-\w]/g, ''),
        date: randomDate(new Date(2005, 0, 1), new Date()),
        category: _.sample(categories),
        cover: "http://lorempixel.com/g/640/480/" + _.sample(['people', 'city', 'fashion', 'nature', 'nightlife', 'transport']) + '/' + _.random(1, 10),
        tags: _.sample(tags, _.random(2,5))
      }
      return fs.outputFileAsync(
        path.join(__dirname, '..', 'data/posts/', data.slug + '.md'),
        "---\n" + yaml.safeDump(data) + "---\n" + _.reduce(_.range(3,10), function(memo, index){
          memo += faker.Lorem.paragraph(_.random(2,5)) + '.\n\n'
          return memo
        }, '')
      )
    }))
  })
}
