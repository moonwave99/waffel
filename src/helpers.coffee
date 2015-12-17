_       = require 'lodash'

module.exports =
  url: (name, data = {}, options = {}) ->
    wfl = _.last arguments
    _page = arguments[arguments.length-2]
    _.merge options, _page
    page = wfl._getPageByName name
    if options.page
      page.pagination =
        page: options.page
    if wfl.options.uglyUrls
      relativeUrl = wfl._url page, data, options
      if wfl.options.displayExt
        (_.compact( [wfl.options.domain, wfl.options.basePath, (relativeUrl || 'index')] ).join '/') + wfl.options.outputExt
      else
        _.compact( [wfl.options.domain, wfl.options.basePath, relativeUrl] ).join '/'
    else
      _.compact( [wfl.options.domain, wfl.options.basePath, (wfl._url page, data, options), 'index.html'] ).join '/'

  asset: (_path = '') ->
    wfl = _.last arguments
    _.compact( [wfl.options.domain, wfl.options.basePath, wfl.options.assetPath, _path] ).join '/'

  absoluteURL: (url) ->
    wfl = _.last arguments
    _.compact( [wfl.options.domain, wfl.options.basePath, url] ).join '/'

  t: (key) ->
    wfl = _.last arguments
    page = arguments[arguments.length-2]
    wfl.i18n key, lng: page.language

  loc: (data = {}, language) ->
    wfl = _.last arguments
    language = language or wfl.options.defaultLanguage
    if _.isArray data
      data.map (item) =>
        if item._localised then item[language] or item[wfl.options.fallbackLanguage] else item
    else if not data._localised
      data
    else
      data[language] or data[wfl.options.fallbackLanguage]
