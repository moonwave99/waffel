filters       = require './filters'
helpers       = require './helpers'
utils         = require './utils'

_             = require 'lodash'
colors        = require 'colors'
exec          = require('child_process').exec
chokidar      = require 'chokidar'
Promise       = require 'bluebird'
path          = require 'path'
md5           = require 'md5'
glob          = require 'globby'
EventEmitter  = require('events').EventEmitter
util          = require 'util'
async         = require 'async'
yaml          = require 'js-yaml'
matter        = require 'gray-matter'
i18n          = require 'i18next'
Backend       = require 'i18next-node-fs-backend'
moment        = require 'moment'
nunjucks      = require 'nunjucks'
markdown      = require 'nunjucks-markdown'
marked        = require 'marked'
cheerio       = require 'cheerio'
pushserve     = require 'pushserve'

fs            = Promise.promisifyAll require 'fs-extra'

module.exports = class Waffel extends EventEmitter
  defaults:
    silent:             false
    verbose:            false
    versionAssets:      false
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
    basePath:           ''
    assetPath:          ''
    root:               process.cwd()
    dataExt:            '.md'
    templateExt:        '.html'
    languages:          []
    defaultLanguage:    'en'
    fallbackLanguage:   'en'
    localiseDefault:    false
    sitemap:            true
    sitemapName:        'sitemap.xml'
    uglyUrls:           false
    outputExt:          '.html'
    displayExt:         true
    dateFormat:         'YYYY-MM-DD'
    server:             false
    watch:              false
    watchInterval:      5000
    config:
      env:              'dev'
    markdownOptions:
      gfm:          true
      tables:       true
      smartLists:   true
      smartypants:  false
    frontmatter:
      delims: ['---', '---']
    serverConfig:
      port:       1999
      path:       'public'
      indexPath:  'public/404.html'

  log: =>
    console.log.apply null, arguments if not @options.silent

  error: (what, e) =>
    console.log util.inspect(what, false, 2, true) if @options.verbose
    console.error e.stack

  constructor: (opts) ->
    @options = _.extend {}, @defaults, opts
    ['dataFolder', 'viewFolder', 'staticFolder', 'localesFolder', 'destinationFolder', 'structureFile'].forEach (f) =>
      @options[f] = path.join @options.root, @options[f]

    @helpers = _.extend {}, helpers, @options.helpers
    @filters = _.extend {}, filters, @options.filters

    @filters.loc      = _.memoize @filters.loc, (data, language)  -> "#{data[0]._collection}_#{language}"
    @filters.excerpt  = _.memoize @filters.excerpt, (text, size)  -> "#{md5(text)}.#{size}"
    @filters.top      = _.memoize @filters.top, (data, size)      -> "#{_.flattenDeep data .join ''}.#{size}"

    @data = {}

    try structureFileContents = fs.readFileSync @options.structureFile, 'utf8'
    catch e then @error "Could not locate structureFile: #{@options.structureFile}", e
    site = yaml.safeLoad structureFileContents

    @config = _.extend @options.config, site.config
    @structure = site.structure

  getRevision: =>
    new Promise (resolve, reject) =>
      exec "git rev-parse HEAD", { cwd: @options.root }, (err, stdout, stderr) =>
        if err then reject err else resolve stdout.split('\n').join ''

  init: =>
    @getRevision().then (commit) =>
      @config.rev = commit
    .catch (e) =>
      @log "--> #{"Could not get commit reference, perhaps not a repo".red}?\n---"

  generate: (options = {}) =>
    @log "--> Start generation process...\n---"
    dataPaths = [
      path.join @options.dataFolder, "**/*#{@options.dataExt}"
      path.join @options.dataFolder, "**/*.json"
    ]

    if @options.watch
      localesPath = path.join @options.localesFolder, "**/*.json"
      viewPath    = path.join @options.viewFolder, "**/*"
      debounced_generate = _.debounce =>
        @_generate dataPaths, options
        , @options.watchInterval
      @watcher = chokidar.watch dataPaths.concat [localesPath, viewPath]
      @watcher.on 'change', debounced_generate
    @_generate dataPaths, options

  postGenerate: (err, pages) =>
    elapsed = process.hrtime @start
    millis = elapsed[1] / 1000000
    @log "--> Generated #{(pages.length + '').cyan} pages in #{elapsed[0]}.#{millis.toFixed(0)}s."
    if @options.sitemap
      @_generateSitemap(pages).then => @emit 'generation:complete'
    else
      @emit 'generation:complete'
    @_launchServer() if @options.server and !@serverStarted

  _loadLocales: =>
    new Promise (resolve, reject) =>
      _i18n = i18n.createInstance()
      .use(Backend)
      .init
        debug:    @options.verbose
        preload:  @options.languages.concat ['dev']
        lng:      @options.defaultLanguage
        backend:
          loadPath: path.join @options.localesFolder, '{{lng}}.json'
      , (err, t) ->
        if err then reject err else resolve t
    .then (t)=>
      @i18n = t
      @

  _registerTemplates: =>
    @env = nunjucks.configure @options.viewFolder,
      watch: false
      express: null
      autoescape: false
    for name, filter of @filters
      @env.addFilter name, filter.bind @

    marked.setOptions @options.markdownOptions
    markdown.register @env, marked
    nunjucks.precompile @options.viewFolder, { env: @env }

  _getFiles: (dataPaths = []) =>
    Promise.all dataPaths.map (_path) =>
      @log "--> Globbing #{_path.cyan}:"
      glob(_path).then (files) =>
        _data = {}
        files.forEach (file) =>
          if path.extname(file) == '.json'
            collection = path.basename file, '.json'
            _data[collection] = fs.readJsonSync file
          else
            @_parseFile file, _data
        _data
    .then (data) =>
      mergedData = {}
      data.forEach (x) => _.merge mergedData, x
      mergedData

  _generate: (dataPaths, options) =>
    @._loadLocales().then =>
      @_registerTemplates()
      @start = process.hrtime()
      @emit 'generation:start'
      @_getFiles(dataPaths).then (data) =>
        @data = data
        if options.data then _.merge @data, options.data
        fs.ensureDirAsync( @options.destinationFolder ).then =>
          tasks = []
          languages = if @options.localiseDefault then @options.languages else @options.languages.filter (l) => l != @options.defaultLanguage
          for language in languages
            tasks = tasks.concat @_generateForLanguage language, true
          tasks = tasks.concat @_generateForLanguage @options.defaultLanguage, false
          async.parallel tasks, @postGenerate

  _generateForLanguage: (language, localised) =>
    tasks = []
    for name, page of @structure
      if page.languages and language not in page.languages
        @log "#{"Notice:".magenta} #{name.green} won't be rendered in #{language.yellow}" if @options.verbose
      else if page.template
        page.name = name
        url = @_url page, {}, { language: language, localised: localised }
        tasks.push @_createPage page, name, url, {}, language, localised
      else if page.collection
        for _name, _page of page.pages
          _page.name = "#{name}.#{_name}"
          if _name is 'single'
            tasks = tasks.concat _.compact @_createSinglePages _page, "#{name}.single", @data[page.collection], language, localised
          else
            tasks = tasks.concat _.compact @_createCollectionPage _page, "#{name}.#{_name}", @data[page.collection], language, localised
    tasks

  _parseFile: (file, _data) =>
    relativePath = utils.relativisePath file, @options.dataFolder
    tokens = relativePath.split(path.sep).slice 1
    collection = tokens[0]
    _data[collection] ||= {}
    loadedData = matter.read file, delims: @options.frontmatter.delims
    data = loadedData.data
    data.__content = loadedData.content
    data.slug = data.slug || path.basename relativePath, @options.dataExt
    if tokens[1] in @options.languages
      language = tokens[1]
      _data[collection][data.slug] ||= { _localised: true, _collection: collection }
      _data[collection][data.slug][language] = data
    else
      _data[collection][data.slug] = data

  _getPageByName: (name) =>
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

  _formatToken: (value = '') =>
    if value instanceof Date
      value = moment(value).format @options.dateFormat
    @_slugify value

  _url: (page, data, opts = {}) ->
    tokens = page.url.split('/')
    tokens.unshift opts.language if opts.localised
    tokens = tokens.map (token) =>
      if token[0] is ':' then (@_formatToken data.group or data[token.slice 1]) else token

    if page.pagination and page.pagination.page > 1
      tokens.push 'page'
      tokens.push page.pagination.page

    _.compact(tokens).join('/')

  _target: (url) =>
    ext = path.extname url
    if ext
      path.join @options.destinationFolder, url
    else if @options.uglyUrls and url.length > 0
      path.join @options.destinationFolder, "#{url}#{@options.outputExt}"
    else
      path.join @options.destinationFolder, url, "index#{@options.outputExt}"

  _renderPage: (page, _data) =>
    tmpData = {}
    tmpData[page.export || 'item'] = _data
    try
      nunjucks.render "#{page.template}#{@options.templateExt}",
        _.extend {}, @_getHelpers(page), tmpData,
          options : @options
          config  : @config
          data    : @data
          page    : page
    catch error
      switch error.name
        when 'Template render error' then @_printTemplateError error, page, _data
        else @error page, error

  _printTemplateError: (error, page, data) ->
    if errorInfo = error.message.match /template not found: (.*)/i
      message = "#{"Template not found: ".red} #{errorInfo[1].green}"
      info = error.message.split("\n")[0]
    else if errorInfo = error.message.match /Template render error: (.*) \[Line (\d+), Column (\d+)\]/
      message = "#{"Syntax Error:".red} #{error.message.split("\n").pop().trim().green}"
      info = "#{errorInfo[1]} [Line #{errorInfo[2]}, Column #{errorInfo[3]}]"
    else
      errorInfo = error.message.split("\n").map (x) -> x.trim()
      info = errorInfo[0]
      message = "#{"Syntax Error:".red} #{errorInfo[1].green}"

    console.log "#{message}\n#{info.yellow}\n"

  _createCollectionPage: (page, name, set, language, localised) =>
    sort = if page.sort and page.sort.field then page.sort.field else @options.defaultSortField
    order = if page.sort and page.sort.order then page.sort.order else @options.defaultSortOrder

    set = _.reduce set, (memo, item, key) ->
      if item._localised and item[language]
        memo[key] = item[language]
      else
        memo[key] = item
      memo
    , {}

    if page['filter']
      set = _.where set, page['filter']
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
      pages = _(set).sortBy(sort).tap (x) ->
          if order is 'desc' then _ x .reverse() else x
        .chunk(page.paginate or @options.defaultPagination)
        .value()

      if page.pageLimit
        pages = pages.slice 0, Math.abs +page.pageLimit

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

  _createSinglePages: (page, name, set, language, localised) =>
    _.map set, (item, slug) =>
      data = if item._localised then item[language] or item[@options.fallbackLanguage] else item
      if page.filter and not _.where([data], page.filter).length then return false
      url = @_url page, data, { language: language, localised: localised }
      @_createPage page, name, url, data, language, localised

  _createPage: (page, name, url, data = {}, language, localised) =>
    (callback) =>
      target = @_target url
      _page = _.clone page
      _page.path = url
      _page.language = language
      _page.localised = localised
      output = @_renderPage _page, data
      languageInfo = if localised then "[#{language}] " else '[--] '
      paginationInfo = if page.pagination then " #{page.pagination.page}/#{page.pagination.total}" else ''
      pageInfo = data.slug || data.group || page.group || ''
      pageInfo = if pageInfo then " [#{pageInfo}]" else ''
      @log "#{languageInfo.red}Generating #{name.green}#{pageInfo.yellow}#{paginationInfo.magenta} at: #{target.cyan}" if @options.verbose
      fs.outputFile target, output, (err) =>
        callback err, page: _page, data: data, url: url

  _generateSitemap: (pages) =>
    target = path.join @options.destinationFolder, @options.sitemapName
    output = nunjucks.render @options.sitemapName,
      _.extend {}, @_getHelpers(),
        options : @options
        config  : @config
        data    : @data
        pages   : pages.filter (p) -> !_.isBoolean p.page.sitemap and p.page.sitemap is not false
        now     : new Date
    fs.outputFileAsync(target, output).then =>
      @log "--> Created #{@options.sitemapName.cyan}"
      true

  _getHelpers: (context = {})=>
    _.transform @helpers, (help, func, key) =>
      help[key] = =>
        [].push.call arguments, context
        [].push.call arguments, @
        func.apply null, arguments

  _launchServer: =>
    opts = _.extend {}, @options.serverConfig, @options.server
    server = pushserve opts, =>
      @log "--> waffel server waiting for you at " + "http://localhost:#{opts.port}".green
      @emit 'server:start', server
      @serverStarted = true
