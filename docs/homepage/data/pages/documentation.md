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

## Why wfl.init().then( ... )?

This way, you have the chance to intercept the `data` after parsing the files but before generating the actual website.

## Options

You can pass an hash of options to Waffel at creation time, like:

    var Waffel = require('waffel')
    ...
    var wfl = new Waffel({
      domain: 'http://www.example.com',
      ...
    })

Let's inspect what's available:

| Name                  | Description                                                                          | Accepts | Default         |
|-----------------------|--------------------------------------------------------------------------------------|---------|-----------------|
| `silent`              | Suppresses all log outputs.                                                          | boolean | `false`         |
| `verbose`             | Prints single page generation information.                                           | boolean | `false`         |
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
| `sitemap`             | If true, generates sitemap.                                                          | boolean | `true`          |
| `sitemapName`         | Sitemap filename.                                                                    | string  | `sitemap.xml`   |
| `server`              | Starts a webserver, useful for `dev` environment.                                    | boolean | `false`         |
| `root`                | Project root folder.                                                                 | string  | `process.cwd()` |
| `dataExt`             | Data files extension.                                                                | string  | `.md`           |
| `templateExt`         | Template files extension.                                                            | string  | `.html`         |
| `languages`           | Languages supported by website.                                                      | array   | `[]`            |
| `defaultLanguage`     | Website default language (as ISO two-letter code).                                   | string  | `en`            |
| `fallbackLanguage`    | Language used if document is not present in current language.                        | string  | `en`            |
| `localiseDefault`     | If `true`, prepends language slug portion even to default language documents.        | boolean | `false`         |
| `uglyUrls`            | Generates `name.html` style documents, as opposed to  `name/index.html`.             | boolean | `false`         |
| `outputExt`           | Output document file extension.                                                      | string  | `.html`         |
| `displayExt`          | If 'false', omits file extension (useful when uploading to S3 for instance).         | boolean | `true`          |
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
