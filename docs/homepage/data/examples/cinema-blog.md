---
title: A Cinema Blog, à la Jekyll
slug: cinema-blog-ala-jekyll
cover: annie-hall.jpg
---
[Jekyll](http://www.jekyll.io) is the static blog generation staple. Let's mimic its behaviour in Waffel!

[See live demo here »](/waffel/examples/cinema-blog-ala-jekyll/demo/index.html).

## Goal

We are going to generate a blog that thoroughly reviews [the best 1000 movies ever, according to NY Times](http://www.nytimes.com/ref/movies/1000best.html).  
First, you would like to have a look at it yourself, so generate it via:

    $ npm install
    $ node index.js
    
Et voilà, point your browser to the URL written in your console (with all chance, [http://localhost:1337](http://localhost:1337)) and browse around.

Cool! Fast! Tell me more about how you made it!

## Walktrough

### The `structureFile`.

Sure, here we go. As you may have already read, Waffel generates output from website content (by default located in `/data`), following the instructions contained in the `structureFile`(namely `site.yml`). No configuration in any file / YAML frontmatter, because the old concern separation adagio still holds.

Let's check the `structure` part of the  `structureFile`:

    structure:
      blog:
        collection: posts
        pages:
          index:
            template: blog/index
            url:      /
            priority: 0.5
            sort:
              field: date
              order: desc
          categories:
            template: blog/category
            url:      /category/:category
            groupBy:  category
            priority: 0.5
            sort:
              field: date
              order: desc        
          tags:
            template: blog/tag
            url:      /tag/:tag
            groupBy:  tags
            changefreq: weekly
            priority: 0.7
            sort:
              field: date
              order: desc
          single:
            template: blog/post
            url:      /posts/:slug
            priority: 0.8
      about:
        template: about
        url: /about
      404:
        template: 404
        url: /404
        sitemap:  false
        
We have a `blog` section, holding three `pages`:

- `index` is the list of **all posts**, that will serve as homepage (simply because its URL schema is `/`);
- `categories` is a _set_ of pages, one per **category** (among all categories used over all posts, in this case _classic_, _independent_, _avantgarde_);
- `tags`: as above, but referred to **tags**.

Notice the `collection` property (set to `posts`): Waffel will tie the `blog` section to the list of posts, and generate pages accordingly.

And what does `groupBy` do? It tells Waffel to generate a different page for every single instance of the given property all over the `collection` - in this case, for the `categories` page we get:

    /category/avantgarde/index.html
    /category/classic/index.html
    /category/independent/index.html

For `tags`:

    /tag/247/index.html
    /tag/b2b/index.html
    /tag/back-end/index.html
    /tag/best-of-breed/index.html
    /tag/bricks-and-clicks/index.html
    /tag/clicks-and-mortar/index.html
    /tag/collaborative/index.html
    /tag/cross-media/index.html
    /tag/customized/index.html
    /tag/cutting-edge/index.html
    ...
    /tag/web-enabled/index.html
    /tag/wireless/index.html
    world-class/index.html

(_silly random buzzwords, may vary across different generations_)

On top of that, every `page` is sorted according to the `sort` field, and is paginated in chunks whose default size is 10.

A different one can be provided via `paginate` parameter, e.g.:

    tags:
      template: blog/tag
      url:      /tag/:tag
      groupBy:  tags
      paginate: 20

There is so just one property not covered yet, the `template`!

    
### Templates

Waffel uses [Nunjucks](https://mozilla.github.io/nunjucks/), due to its expressiveness.
