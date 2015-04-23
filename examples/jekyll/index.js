var Waffel = require('Waffel')
var fs = require('fs-extra')
var _ = require('lodash')
var faker = require('faker')
var yaml = require('yaml-front-matter')

// We fake some data here.
// [ignore this, as it merely fixtures data for example's sake]
var movies = fs.readFileSync('movies.txt').toString().split("\n")
var categories = ['classic', 'independent', 'avantgarde']
var tags = _.reduce(_.range(25), function(memo, index){
  memo.push(faker.random.bs_buzz())
  return memo
}, [])
tags = _.uniq(tags)

function randomDate(start, end) {
  return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
}

movies.forEach(function(movie, index){
  var data = {
    title: movie,
    slug: movie.toLowerCase().replace(/\s+/g, '-').replace(/[^-\w]/g, ''),
    date: randomDate(new Date(2005, 0, 1), new Date()),
    category: _.sample(categories),
    cover: "http://lorempixel.com/g/640/480/" + _.sample(['people', 'city', 'fashion', 'nature', 'nightlife', 'transport']) + '/' + _.random(1, 10),
    tags: _.sample(tags, _.random(2,5))
  }
  
  fs.outputFileSync(
    __dirname + '/data/posts/' + data.slug + '.md',
    "---\n" + yaml.safeDump(data) + "---\n" + _.reduce(_.range(3,10), function(memo, index){
      memo += faker.Lorem.paragraph(_.random(2,5)) + '\n\n'
      return memo
    }, '')
  )
})

// We do the Waffel stuff here.
var port = 1337
var wfl = new Waffel({
  domain: "http://localhost:" + port,
  server: true,
  serverConfig: { port: port, path: 'public' }
})

wfl.init().then(function(){
  wfl.generate()
})