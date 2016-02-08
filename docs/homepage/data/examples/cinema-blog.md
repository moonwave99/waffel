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

We have a `blog` section, holding four `pages`:

- `index` is the list of **all posts**, that will serve as homepage (simply because its URL schema is `/`);
- `categories` is a _set_ of pages, one per **category** (among all categories used over all posts, in this case _classic_, _independent_, _avantgarde_);
- `tags`: as above, but referred to **tags**;
- `single`: **all single post pages**, that will result in separate HTML documents.

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

Waffel uses [Nunjucks](https://mozilla.github.io/nunjucks/), due to its expressiveness. Let's check in detail what happens in the [single post template](https://github.com/moonwave99/waffel/blob/master/docs/examples/jekyll/views/blog/post.html):

    {% extends "layout.html" %}

Extending another template (in this case [`layout.html`](https://github.com/moonwave99/waffel/blob/master/docs/examples/jekyll/views/layout.html)) means to reuse its structure by adding further content in any of its **blocks**:

```
{% block meta %}
  <meta name="description" content="{{ item.__content | excerpt(150) }}">
  <meta property="og:type" content="article">
  <meta property="og:description" content="{{ item.__content | excerpt(350) }}">
  <meta property="article:published_time" content="{{ item.date | format('YYYY-MM-DDTHH:mm:ss.SSSZZ') }}">
  {% for tag in item.tags %}
  <meta property="article:tag" content="{{ tag }}">
  {% endfor %}
  <meta name="twitter:description" content="{{ item.__content | excerpt(350) }}">
{% endblock %}
```

This snippet for instance, adds meta tags information in the `meta` block, that is located in the [`base.html`](https://github.com/moonwave99/waffel/blob/master/docs/examples/jekyll/views/base.html#L6) template.

[Nunjucks docs cover the topic pretty well here](https://mozilla.github.io/nunjucks/templating.html#template-inheritance)! Concerning specific Waffel topics, you can see many references to the `item` variable. It holds **data for the current page**, in this case for the single blog post.

For instance, in order to fill the `description` metatag, we apply the `excerpt()` filter to the `__content` property of the post, that holds its Markdown formatted content. Unsurprisingly, it will fill it with an excerpt of the blogpost!

**Note:** the `excerpt()` filter is a bit expensive in terms of computation, that's why it has been cleverly memoized. Feel free to use it in different parts of the website, e.g. for metatag information and post previews or related posts cards!

---

Going further down to the `body` block, we meet the `url()` helper for the first time:

```
<header>
  <h1>{{ item.title }}</h1>
  <p><img src="{{ item.cover }}" class="img-responsive" alt="{{ item.title }}"></p>
  <p class="info">Written on <strong>{{ item.date | format('MMM DD YYYY') }}</strong> in <a href="{{ url('blog.categories', item) }}">{{ item.category | capitalize }}</a></p>
</header>
```

It helps generating URLs for internal document references, keeping thus the hypertext graph consistent - read: if you change your URL names in the future, they will be generated accordingly.
In this case, we generate a category page URL (e.g. /category/classic/index.html) by calling `url('blog.categories', { category: item.category })`.

Notice how we passed `item` as the second parameter: this is an useful shorthand that works because `item` has a `category` field itself! Waffel will just access the property defined in the `groupBy` URL option, in order to generate the final URL.

In case you would want to generate an URL for a _different_ category page, you will have to state it explicitly, i.e. `url('blog.categories', { category: 'another-category' })`.

---

We use then the `markdown` tag, in order to render `item.__content` as HTML:

```
{% markdown %}{{ item.__content }}{% endmarkdown %}
```

Note that due to some Nunjucks/marked bug, markdown blocks shall **always be completely left aligned**, i.e. no tab/indentation at all before `{% markdown }`, sorry.

---

Further explanation regarding other templates used in this example will come soon.
