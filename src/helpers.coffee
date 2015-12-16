_       = require 'lodash'
i18n    = require 'i18next'

module.exports =
  url: (name, data = {}, options = {}) ->
    _.merge options, _.last arguments
    page = @_getPageByName name
    if options.page
      page.pagination =
        page: options.page
    if @options.uglyUrls
      relativeUrl = @_url page, data, options
      if @options.displayExt
        (_.compact( [@options.domain, @options.basePath, (relativeUrl || 'index')] ).join '/') + @options.outputExt
      else
        _.compact( [@options.domain, @options.basePath, relativeUrl] ).join '/'
    else
      _.compact( [@options.domain, @options.basePath, (@_url page, data, options), 'index.html'] ).join '/'

  asset: (_path = '') ->
    _.compact( [@options.domain, @options.basePath, @options.assetPath, _path] ).join '/'

  absoluteURL: (url) ->
    _.compact( [@options.domain, @options.basePath, url] ).join '/'

  t: (key) ->
    page = _.last arguments
    i18n.translate key, lng: page.language

  loc: (data = {}, language = @options.defaultLanguage) ->
    if _.isArray data
      data.map (item) =>
        if item._localised then item[language] or item[@options.fallbackLanguage] else item
    else if not data._localised
      data
    else
      data[language] or data[@options.fallbackLanguage]
