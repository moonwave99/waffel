_       = require 'lodash'

_propertiesToPick = ['language', 'localised', 'page']

module.exports =
  classes: (classes = {}) ->
    output = []
    for className, value of classes
      if value then output.push className
    output.join ''
      
  url: (name, data = {}, options = {}) ->
    _.merge _.pick(arguments[arguments.length-2], _propertiesToPick), options
    wfl = _.last arguments
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
      _.compact( [wfl.options.domain, wfl.options.basePath, (wfl._url page, data, options), "index#{wfl.options.outputExt}"] ).join '/'

  asset: (_path = '', options = {}) ->
    wfl = _.last arguments
    if wfl.options.versionAssets and wfl.config.rev and options.versioned
      [base, ext] = _path.split('.')
      _path = "#{base}_#{wfl.config.rev}.#{ext}"
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
    page = arguments[arguments.length-2]
    language = if wfl.options.languages.indexOf(language) > -1 then language else page.language or wfl.options.defaultLanguage
    if _.isArray data
      data.map (item) =>
        if item._localised then item[language] or item[wfl.options.fallbackLanguage] else item
    else if not data._localised
      data
    else
      data[language] or data[wfl.options.fallbackLanguage]
