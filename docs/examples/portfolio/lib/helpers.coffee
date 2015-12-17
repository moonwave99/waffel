_ = require 'lodash'

module.exports =
  imgInfo: (img) ->
    wfl = _.last arguments
    wfl.data.imgInfo[img] or {}
