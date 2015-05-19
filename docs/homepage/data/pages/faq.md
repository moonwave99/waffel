## FAQ

> Does Waffel work with different front matter formats (e.g. JSON, TOML,…) rather than YAML?

Not at the moment, though I would be glad to [receive a PR](https://github.com/moonwave99/waffel) in order to make front matter format configurable!

> Is there any CLI tool?

No, because [brunch](http://brunch.io/), [gulp](http://gulpjs.com/) and [grunt](http://gruntjs.com/) all make a wonderful job at that.

> Does Waffel handle the compilation/concatenation/minification of my CSS/JS code?

No, because [brunch](http://brunch.io/), [gulp](http://gulpjs.com/) and [grunt](http://gruntjs.com/) all make a wonderful job at that.

> Can I change template language?

Not at the moment, because I like [Nunjucks](https://mozilla.github.io/nunjucks/)'s expressiveness a lot, and the possibility to **chain filters** (that allows me to use more logic in templates, since there is no controller layer actually).

> Does Waffel provide support for a complex relational model?

Waffel doesn't know anything about your data schema. But as all the loaded data is exposed in the templates via the `data` property, you can deal with any sort of composition (e.g. `data.users[post.author]`). It's the price to pay if you don't have to write a schema, but I don't find it very high : ))

In case you really need a complex query mechanism, chances are that you need a different stack.

> Are there plugins? Is there a way to write any?

Writing a plugin for such a specific tool usually ends up in following a narrow DSL, with no real benefit on top of that hassle.  
You can include even complicate **filters** and **helpers**, that can be used all over the HTML template codes.

Nevertheless, have a look at the examples up here, they may help you to achieve your goal!