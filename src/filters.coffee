_             = require 'lodash'
util          = require 'util'
moment        = require 'moment'
marked        = require 'marked'
cheerio       = require 'cheerio'

lodash_filters = ['toArray', 'pluck', 'flatten', 'uniq', 'where', 'findWhere', 'compact']

filters =
  limit: (array = [], count = 10) ->
    array.slice 0, count

  format: (date, format, locale = @options.defaultLanguage) ->
    moment.locale locale
    moment(date).format format || @options.dateFormat

  excerpt: (text, size = 200) ->
    $ = cheerio.load marked text
    text = $('p').filter (index, element) ->
        (element.children[0].type == 'text') || _.contains ['em', 'strong'], element.children[0].name
      .first().text().trim()
    if text.length > size
      words = text.substring(0,size).split(' ')
      words.pop()
      "#{words.join ' '}…"
    else
      text

  toJSON: (data) ->
    JSON.stringify data

  inspect: (object) ->
    console.log util.inspect(object, false, 2, true)
    object

  top: (data, thresh = 3) ->
    data = _.flatten data
    data = _.reduce data,
      (memo, x) ->
        if memo[x] then memo[x] = memo[x]+1 else memo[x] = 1
        memo
      , {}
    data = _.reduce data,
      (memo, freq, key) ->
        memo.push { key: key, freq: freq }
        memo
      , []
    data = _.sortBy data, (bin) -> -bin.freq
    data.slice(0, thresh).map (x) -> x.key

  loc: (data, language) ->
    if _.isArray data
      data.map (item) =>
        if item._localised then item[language] or item[@options.fallbackLanguage] else item
    else if not data._localised
      data
    else
      data[language] or data[@options.fallbackLanguage]

lodash_filters.forEach (m) ->
  filters[m] = _[m]

module.exports = filters
