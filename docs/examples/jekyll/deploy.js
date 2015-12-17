var _         = require('lodash')
var Waffel    = require('../../../lib/index')
var Promise   = require('bluebird')
var generator = require('./lib/generator')

module.exports = function(options){
  generator()

  return new Promise(function(resolve, reject){
    var wfl = new Waffel(_.extend(options, {
      root: __dirname
    }))

    wfl.init().then(function(){
      wfl.generate()
      resolve(wfl)
    })
  })

}
