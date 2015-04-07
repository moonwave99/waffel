_         = require 'lodash'
colors    = require 'colors'
Promise   = require 'bluebird'
path      = require 'path'
async     = require 'async'
yaml      = require 'yaml-front-matter'
fs        = Promise.promisifyAll require 'fs-extra'
glob      = Promise.promisifyAll require 'globby'
i18n      = require 'i18next'
moment    = require 'moment'
nunjucks  = require 'nunjucks'
markdown  = require 'nunjucks-markdown'
marked    = require 'marked'

module.exports = class Waffel
  brunchPlugin: yes
  defaults:
    verbose:            true
    defaultPagination:  10    
    defaultSortField:   'slug'
    defaultSortOrder:   'desc'
    structureFile:      'site.yml'
    viewFolder:         'views'
    dataFolder:         'data'
    destinationFolder:  'public'
    staticFolder:       'assets'
    localesFolder:      'locales'
    domain:             ''
    assetPath:          ''
    root:               process.cwd()
    ext:                '.md'
    templateExt:        '.html'
    languages:          []
    defaultLanguage:    'en'
    fallbackLanguage:   'en'
    sitemap:            true
    dateFormat:         'YYYY-MM-DD'
    
  helpers:
    url: (name, data = {}, options = {}) ->
      page = @_getPageByName name      
      _.compact( [@options.domain, (@_url page, data, options), 'index.html'] ).join '/'
    asset: (_path = '') ->
      _.compact( [@options.domain, @options.assetPath, _path] ).join '/'
    absoluteURL: (url) ->
      _.compact( [@options.domain, url] ).join '/'
    t: (key, page) ->
      i18n.translate key, lng: page.language
      
  filters:
    toArray: (object) ->
      _.toArray object
    
    limit: (array = [], count = 10) ->
      array.slice 0, count
    
    format: (date, format = @options.dateFormat) ->
      moment(date).format format          
      
  constructor: (opts) ->
    @options = _.extend @defaults, opts
    @options.dataFolder         = path.join @options.root, @options.dataFolder
    @options.viewFolder         = path.join @options.root, @options.viewFolder
    @options.staticFolder       = path.join @options.root, @options.staticFolder
    @options.localesFolder      = path.join @options.root, @options.localesFolder
    @options.destinationFolder  = path.join @options.root, @options.destinationFolder
    @options.structureFile      = path.join @options.root, @options.structureFile

    for name, helper of @helpers
      @helpers[name] = _.bind helper, @

    for name, filter of @filters
      @filters[name] = _.bind filter, @

    @data = {}

    site = yaml.safeLoad fs.readFileSync(@options.structureFile, 'utf8')

    @config = site.config
    @structure = site.structure
    @registerTemplates()

  registerTemplates: ->
    @env = nunjucks.configure @options.viewFolder
    for name, filter of @filters
      @env.addFilter name, filter.bind @
    
    markdown.register @env, marked
    nunjucks.precompile @options.viewFolder, { env: @env }
    
  init: ->
    _path = path.join(@options.dataFolder, "**/*#{@options.ext}")
    console.log "--> Globbing #{_path.cyan}:"
    i18n.init
      preload: @options.languages.concat ['dev']
      lng: @options.defaultLanguage
      fallbackLng: 'dev'
      resGetPath: path.join @options.localesFolder, '__lng__.json'
      
    glob.callAsync( @, _path).then (files) =>
      files.forEach @_parseFile, @
      @data
          
  generate: ->
    structure = yaml.safeLoad()
    @start = process.hrtime()
    console.log "--> Start generation process...\n---"
    fs.ensureDirAsync( @options.destinationFolder ).then =>
      tasks = []
      for language in @options.languages
        tasks = tasks.concat @_generateForLanguage language, true
      tasks = tasks.concat @_generateForLanguage @options.defaultLanguage, false  
      
      async.parallel tasks, @postGenerate
      
  postGenerate: (err, pages) =>
    elapsed = process.hrtime(@start)
    millis = elapsed[1] / 1000000
    console.log "--> Generated #{(pages.length + '').cyan} pages in #{elapsed[0]}.#{millis.toFixed(0)}s."
    @_createSitemap pages if @options.sitemap
  
  _generateForLanguage: (language, localised) ->
    tasks = []
    for name, page of @structure
      if page.template
        url = @_url page, {}, { language: language, localised: localised }
        tasks.push @_createPage page, name, url, {}, language, localised
      else if page.collection
        for _name, _page of page.pages
          if _name is 'single'
            tasks = tasks.concat @_createSinglePages _page, "#{name}.single", @data[page.collection], language, localised
          else
            tasks = tasks.concat @_createCollectionPage _page, "#{name}.#{_name}", @data[page.collection], language, localised
    tasks
    
  _parseFile: (file) ->
    relativePath = file.replace @options.dataFolder, ''
    tokens = relativePath.split(path.sep).slice 1
    collection = tokens[0]
    @data[collection] ||= {}
    data = yaml.loadFront file
    if tokens[1] in @options.languages
      language = tokens[1]
      @data[collection][data.slug] || = { _localised: true }
      @data[collection][data.slug][language] = data
    else
      @data[collection][data.slug] = data
  
  _getPageByName: (name) ->
    tokens = name.split '.'
    if tokens.length == 1
      @structure[name]
    else
      @structure[tokens[0]].pages[tokens[1]]
    
  _slugify: (value = '') ->
    value
      .toLowerCase()
      .replace /\s+/g, '-'
      .replace /[^-\w]/g, ''
     
  _formatToken: (value) ->
    if value instanceof Date
      value = moment(value).format @options.dateFormat
    @_slugify value
    
  _url: (page, data, opts = {}) ->
    tokens = page.url.split '/'
    tokens.unshift opts.language if opts.localised
    tokens = tokens.map (token) =>
      if token[0] is ':'then @_formatToken data.group or data[token.slice 1] else token
        
    if page.pagination and page.pagination.page > 1
      tokens.push 'page'
      tokens.push page.pagination.page
    
    _.compact tokens
      .join '/'
  
  _renderPage: (page, item) ->
    nunjucks.render "#{page.template}#{@options.templateExt}",
      _.extend @helpers,
        options : @options
        config  : @config
        data    : @data
        page    : page
        item    : item

  _createCollectionPage: (page, name, set, language, localised) ->
    sort = if page.sort and page.sort.field then page.sort.field else @options.defaultSortField
    order = if page.sort and page.sort.order then page.sort.order else @options.defaultSortOrder

    if page.groupBy
      sets = {}
      _(set).pluck(page.groupBy).flatten().unique().sort().value().forEach (group) =>
        sets[group] = _.toArray(set).filter (x) =>
          if _(x[page.groupBy]).isArray()
            _.contains x[page.groupBy], group
          else
            x[page.groupBy] is group
    else
      sets = [set]

    tasks = _.map sets, (set, group) =>
      pages = _ set
        .sortBy sort
        .tap (x) ->
          if order is 'desc' then _ x .reverse() else x
        .chunk page.paginate or @options.defaultPagination
        .value()

      pages.map (p, index) =>
        _page = _.clone page
        _page.pagination = 
          page0:  index
          page:   index+1
          total:  pages.length
        _page.group = group
        url = @_url _page, { group: group }, { language: language, localised: localised }
        @_createPage _page, name, url, p, language, localised
      
    _.flatten tasks
    
  _createSinglePages: (page, name, set, language, localised) ->
    _.map set, (item, slug) =>
      data = if item._localised then item[language] or item[@options.fallbackLanguage] else item
      url = @_url page, data, { language: language, localised: localised }
      @_createPage page, name, url, data, language, localised
    
  _createPage: (page, name, url, data = {}, language, localised) ->
    (callback) =>
      target = path.join @options.destinationFolder, url, 'index.html'
      _page = _.clone page
      _page.language = language
      _page.localised = localised
      output = @_renderPage _page, data      
      languageInfo = if localised then "[#{language}] " else '[--] '
      paginationInfo = if page.pagination then " #{page.pagination.page}/#{page.pagination.total}" else ''
      pageInfo = data.slug || data.group || page.group || ''
      pageInfo = if pageInfo then " [#{pageInfo}]" else ''
      console.log "#{languageInfo.red}Generating #{name.green}#{pageInfo.yellow}#{paginationInfo.magenta} at: #{target.cyan}" if @options.verbose
      fs.outputFile target, output, (err) =>
        callback err, page: _page, data: data, url: url
        
  _createSitemap: (pages) ->
    target = path.join @options.destinationFolder, 'sitemap.xml'
    output = nunjucks.render 'sitemap.xml',
      _.extend @helpers,
        options : @options
        config  : @config
        data    : @data
        pages   : pages
        now     : new Date
    fs.outputFile target, output, (err) =>
      console.log "--> Created #{'sitemap.xml'.cyan}"