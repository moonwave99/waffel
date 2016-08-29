_           = require 'lodash'
path        = require 'path'
async       = require 'async'
Promise     = require 'bluebird'
colors      = require 'colors'
glob        = require 'globby'
im          = Promise.promisifyAll require 'imagemagick'

module.exports = (pattern, thumbPath, thumbRelativePath, thumbnailWidth, root = process.cwd(), callback) ->
  thumbnailStartTime = process.hrtime()
  glob(pattern).then (images) ->
    tasks = _.reduce images,  (memo, img) ->
      memo.push ((img) ->
        (parallelCallback) ->
          async.series [
            # get info for original image
            (seriesCallback) ->
              im.identifyAsync(img).then (features) ->
                ratio = features.height / features.width
                ratioPercent = "#{ratio * 100}%"
                seriesCallback null, _(features).pick(['width', 'height']).extend({ src: img.replace("#{root}/data/", ''), ratio: ratio, ratioPercent: ratioPercent }).value()
              .catch seriesCallback
            ,
            # make a thumbnail out of it
            (seriesCallback) ->
              if img.indexOf('/pictures') == -1 then seriesCallback null, null
              else
                im.resizeAsync( srcPath: img, dstPath: "#{thumbPath}/#{path.basename img}", width: thumbnailWidth ).then (stdout, stderr) ->
                  seriesCallback null, "#{thumbRelativePath}/#{path.basename img}"
                .catch seriesCallback
          ],
          (err, results) ->
            info = if results[1] then _.extend results[0], thumb: results[1] else results[0]
            if err then throw err
            parallelCallback err, info

      )(img)
      memo
    ,[]

    async.parallel tasks, (err, data) ->
      if err then throw err
      imgInfo = _.reduce data, (memo, img) ->
          memo[img.src] = img
          memo
        , {}
      elapsed = process.hrtime thumbnailStartTime
      millis = elapsed[1] / 1000000
      console.log "--> Generated #{(data.length + '').cyan} thumbnails in #{elapsed[0]}.#{millis.toFixed(0)}s."
      callback imgInfo
