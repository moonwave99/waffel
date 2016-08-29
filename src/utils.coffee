path = require 'path'

module.exports =
    relativisePath: (filePath = '', basePath = '') ->
        filePath = path.normalize filePath
        basePath = path.normalize basePath
        path.sep + path.relative basePath, filePath
