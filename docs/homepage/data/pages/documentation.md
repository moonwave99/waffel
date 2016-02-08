## (Quick) Start

Okay, there is no real _quick_ start, because Waffel generates websites from a well structured data folder, through a `site.yml` config file and a set of HTML views. So all three elements should be there! Assuming that, this is the bare minimum example for generating your website, and serving its content via Waffel built-in webserver:

    var Waffel = require('waffel')
    var port = 1337;

    var wfl = new Waffel({
      domain:   "http://localhost:" + port,
      server:   true,
      serverConfig: {
        port:       port,
        path:       'public',
        indexPath:  'public/404.html'
      }
    })

    wfl.init().then(function(data){ wfl.generate() })

**Note:** Why `wfl.init().then( ... )`?
This way, you have the chance to intercept the `data` after parsing the files but _before_ generating the actual website, in case that you want to process/merge it with other stuff.

## Events

Waffel instances are [`EventEmitters`](https://nodejs.org/api/events.html#events_class_eventemitter), and emit the following events specifically:

- `generation:start`: emitted when the `generate()` method is called;
- `generation:complete`: emitted after generating all the pages;
- `server:start`: emitted when the built-in webserver is started (if `server: true` was set in the options), after generation is complete.

## Options

You can pass an hash of options to Waffel at creation time, like:

    var Waffel = require('waffel')
    ...
    var wfl = new Waffel({
      domain: 'http://example.com',
      ...
    })

Let's inspect what's available:

| Name                  | Description                                                                          | Accepts | Default         |
|-----------------------|--------------------------------------------------------------------------------------|---------|-----------------|
| `silent`              | If `true`, suppresses all log outputs.                                               | boolean | `false`         |
| `verbose`             | If `true`, prints single page generation information.                                | boolean | `false`         |
| `versionAssets`       | Enables `{versioned:true}` option to append current commit hash to `asset()` helper. | boolean | `false`         |
| `defaultPagination`   | Pagination size.                                                                     | number  | `10`            |
| `defaultSortField`    | Default field for collection sorting.                                                | string  | `slug`          |
| `defaultSortOrder`    | Default order for collection sorting.                                                | string  | `desc`          |
| `structureFile`       | Configuration filename.                                                              | string  | `site.yml`      |
| `viewFolder`          | HTML Views folder.                                                                   | string  | `views`         |
| `dataFolder`          | Data files folder.                                                                   | string  | `data`          |
| `destinationFolder`   | Output folder.                                                                       | string  | `public`        |
| `staticFolder`        | Asset folder. Is copied over verbatim to the `destinationFolder`.                    | string  | `assets`        |
| `localesFolder`       | Folder where translation files are stored.                                           | string  | `locales`       |
| `domain`              | Your website domain, e.g. `http://example.com`.                                      | string  | `""`            |
| `basePath`            | Specify in case your website is being served from anywhere different than `/`.       | string  | `""`            |
| `assetPath`           | If assets are served from a different location/domain than `/`.                      | string  | `""`            |
| `sitemap`             | If `true`, generates sitemap.                                                        | boolean | `true`          |
| `sitemapName`         | Sitemap filename.                                                                    | string  | `sitemap.xml`   |
| `server`              | If `true`, starts a webserver - useful for `dev` environment.                        | boolean | `false`         |
| `root`                | Project root folder.                                                                 | string  | `process.cwd()` |
| `dataExt`             | Data files extension.                                                                | string  | `.md`           |
| `templateExt`         | Template files extension.                                                            | string  | `.html`         |
| `languages`           | Languages supported by website.                                                      | array   | `[]`            |
| `defaultLanguage`     | Website default language (as ISO two-letter code).                                   | string  | `en`            |
| `fallbackLanguage`    | Language used if document is not present in current language.                        | string  | `en`            |
| `localiseDefault`     | If `true`, prepends language slug portion even to default language documents.        | boolean | `false`         |
| `uglyUrls`            | If `true`, Generates `name.html` style documents, as opposed to `name/index.html`.   | boolean | `false`         |
| `outputExt`           | Output document file extension.                                                      | string  | `.html`         |
| `displayExt`          | If `false`, omits file extension (useful when uploading to S3 for instance).         | boolean | `true`          |
| `dateFormat`          | Date format used in slugs.                                                           | string  | `YYYY-MM-DD`    |
| `server`              | If `true`, runs a local webserver - useful for development.                          | boolean | `false`         |
| `watch`               | If `true`, watches `dataFolder` for changes and regenerates website - dev mode only! | boolean | `false`         |
| `watchInterval`       | Debounce interval for watching (in milliseconds).                                    | number  | `5000`          |

---

In addition, you can override local server configuration, whose defaults are:

    serverConfig: {
      port:       1999,
      path:       'public',
      indexPath:  'public/404.html'      
    }

- `port` is the TCP port the server listens from;
- `path` is the folder being served (normally is `destinationFolder`);
- `indexPath` is the document where requests for non existing files are redirected to.

## Helpers

Waffel provides you with some helper methods, to be used in the templates.

### `url(name, data={}, options={})`

Generates a page URL from its name (e.g. `blog.categories`). Accepts a `data` object for passing slug generation parameters (e.g. `{ 'category': item.category }`); in single pages context, it can usually be the `item` itself.

The allowed `options` are:
- `localised`, to generate localised URLs like `/en/category/avantgarde`;
- `language`, the language token to be prepended if `localised` is true;
- `page`, for paginated collections of course, e.g. `/category/avantgarde/page/2`.

**Examples** (given the [jekyll example structure](https://github.com/moonwave99/waffel/blob/master/docs/examples/jekyll/site.yml)):

```
{{ url('about') }}
```
Output: `http://localhost:3333/about/index.html`.

```
{{ url('blog.index', {}, { 'page': 2 }) }}
```
Output: `http://localhost:3333/blog/page/2/index.html`.

```
{{ url('blog.categories', { 'category': 'avantgarde' }, { 'page': 3 }) }}
```
Output: `http://localhost:3333/blog/category/avantgarde/page/2/index.html`.

```
{{ url('blog.tags', { 'tag': 'new' }, { 'localised': true, 'language': 'it' }) }}
```
Output: `http://localhost:3333/it/blog/tag/new/index.html`.

---

**Note:** output assumes default Waffel configuration, i.e. `uglyUrls` set to `false`.

### `asset(_path = '', options = {})`

Generates an asset URL from its relative `_path`, e.g. `/images/background_image.jpg`. If `options.versioned` is `true`, it appends `_#{rev}` to `_path` basename, where `rev` is latest commit hash of current repository (if any).

**Note:** Waffel does not rename your files, you should do on your own before or after generating the website!

**Examples**:

```
{{ asset('js/app.js') }}
```
Output: `http://localhost:3333/js/app.js`.

```
{{ asset('css/app.css', { 'versioned': true }) }}
```
Output: `http://localhost:3333/css/app_be6cb96bd8d3147b571d8452ab4a933df9249618.css`.

### `t(key)`

Exposes `i18next` localisation feature.

### `loc(data={}, language)`

If current page `item` is localised (i.e. holds data stored in different languages), it returns data for required language.

Why not just `item[language]`? Because `loc()` holds logic for fallbacking to default or fallback language, and for dealing with entire collections of items.

So if `item` is:

```
{
  "_localised" : true,
  "en": {
    "title" : "The  Title",
    "category": "the-category"
  },
  "it": {
    "title" : "Il Titolo",
    "category": "la-categoria"
  }  
}
```

`loc(item, 'it')` will return:

```
{
  "title" : "Il Titolo",
  "category": "la-categoria"
}
```

And `loc(item, 'de')` will return:

```
{
  "title" : "The  Title",
  "category": "the-category"
}
```

Because `options.fallbackLanguage` defaults to `en`.

## Filters

Amoung [Nunjucks built-in filters](https://mozilla.github.io/nunjucks/templating.html#builtin-filters), Waffel exposes a bunch of useful ones.

### `Array | limit(count=10)`

Slices array to `count elements`, e.g. `{{ [1,2,3] | limit(2) }}` outputs `[1,2]`.

### `Date | format(format)`

Formats filtered `Date` against provided format, via [moment.js](http://momentjs.com/).

### `String | excerpt(size=200)`

Returns a plain text excerpt of max `size` characters. Memoized for performance.

### `Object | toJSON()`

Exposes `JSON.stringify`. Static API ftw!

### `Object | inspect()`

Taps filtered object, and inspects it in the console. Use like `item | inspect | someOtherFilter`, for debugging purposes.

---

Following [lodash functions](https://lodash.com/docs) are exposed as well: `toArray`, `pluck`, `flatten`, `uniq`, `where`, `findWhere`, `compact`.
