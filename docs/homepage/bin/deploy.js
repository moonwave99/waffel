#! /usr/bin/env node
require('coffee-script/register')

var _       = require('lodash')
var fs      = require('fs-extra')
var path    = require('path')
var colors  = require('colors')
var shell   = require('shelljs')
var ghpages = require('gh-pages')
var Promise = require('bluebird')

console.log("Deploying to gh-pages!".green)
console.log("--> building Waffel website...".yellow)

shell.exec('npm run build')

// examples
var examples = _({
  "jekyll": {
    "destinationFolder": path.join( __dirname, '..', 'dist/examples/cinema-blog-ala-jekyll/demo'),
    "domain": 'http://moonwave99.github.io/waffel/examples/cinema-blog-ala-jekyll/demo',
    "deploy": require("../../examples/jekyll/deploy")
  },
  "portfolio": {
    "destinationFolder": path.join( __dirname, '..', 'dist/examples/portfolio/demo'),
    "domain": 'http://moonwave99.github.io/waffel/examples/portfolio/demo',
    "deploy": require("../../examples/portfolio/deploy")
  }
}).map(function(opts, example){
  return new Promise(function(resolve, reject){
    console.log("--> building " + example + " example...".yellow)
    opts.deploy({
      domain: opts.domain
    }).then(function(wfl){
      wfl.on('generation:complete', function(){
        fs.move(wfl.options.destinationFolder, opts.destinationFolder, { clobber: true }, function(err){
          if(err){
            reject(err)
          }else{
            console.log("--> " + example + " example built with success!".green)
            resolve(opts)
          }
        })
      })
      
    })

  })
  
})

Promise.all(examples.value()).then(function(results){  
  console.log("--> Pushing over to gh-pages...".yellow)
  ghpages.publish(path.join(__dirname, '..', 'dist'), {
    add: true,
    logger: function(message) {
      console.log('[publishing]', message)
    }
  },function(err){
    if(err){
      console.log("--> Ooops, something went wrong : ((".red, err)
    }else{
      console.log("--> Deploy successful, enjoy!".green)
    }
  })
  
})