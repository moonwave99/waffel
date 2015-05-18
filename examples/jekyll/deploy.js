var Waffel = require('Waffel');
var _ = require('lodash');
var generator = require('./lib/generator');

module.exports = function(options){
  generator();
  return new Waffel(_.extend(options, {
    root: __dirname
  }));
}