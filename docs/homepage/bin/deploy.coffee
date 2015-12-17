_       = require 'lodash'
path    = require 'path'
colors  = require 'colors'
shell   = require 'shelljs'
ghpages = require 'gh-pages'
Promise = require 'bluebird'
fs      = Promise.promisifyAll require 'fs-extra'

console.log "Deploying to gh-pages!".green
console.log "--> building Waffel website...".yellow

shell.cd __dirname
shell.exec "npm run clean"
shell.exec "npm run build"

# examples
examples =
  jekyll:
    destinationFolder: path.join __dirname, '..', 'dist/examples/cinema-blog-ala-jekyll/demo'
    domain: 'http://moonwave99.github.io/waffel/examples/cinema-blog-ala-jekyll/demo'
    deploy: require "../../examples/jekyll/deploy"
  portfolio:
    destinationFolder: path.join __dirname, '..', 'dist/examples/portfolio/demo'
    domain: 'http://moonwave99.github.io/waffel/examples/portfolio/demo'
    deploy: require "../../examples/portfolio/deploy"

generate = (name, example) ->
  console.log "--> building #{name} example...".yellow
  example.deploy domain: example.domain
    .then (wfl) ->
      new Promise (resolve, reject) ->
        wfl.on 'generation:complete', ->
          fs.moveAsync wfl.options.destinationFolder, example.destinationFolder, { clobber: true }
            .then ->
              console.log "--> #{name} example built with success!".green
              resolve true

generate 'jekyll', examples.jekyll
  .then ->
    generate 'portfolio', examples.portfolio
  .then ->
    console.log "--> Pushing over to gh-pages...".yellow
    ghpages.publish path.join(__dirname, '..', 'dist'), {
      add: true
      logger: (message) -> console.log '[publishing]', message
    },(err) ->
      if err
        console.log "--> Ooops, something went wrong : ((".red, err
      else
        console.log "--> Deploy successful, enjoy!".green
