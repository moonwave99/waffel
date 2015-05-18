_ = require 'lodash'

module.exports = 
  imgInfo: (img) ->
    @data.imgInfo[img] or {}  