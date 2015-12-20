# Waffel

Static site generation done ~~right~~ _tasty_.

Yet another static generator, here to help you with more concrete use cases than just _your personal blog_.

## Getting Started

I strongly recommend you to use Waffel with [Brunch](http://brunch.io/), starting with the [brunch-with-waffel](https://github.com/moonwave99/brunch-with-waffel) skeleton:

    # in case you do not have Brunch installed yet
    $ npm install brunch -g
    
    $ brunch new path/to/project --skeleton https://github.com/moonwave99/brunch-with-waffel
    $ cd path/to/project
    $ npm start

Visit [`http://localhost:3333`](http://localhost:3333) and you ready to go!

Please have a look at the examples here above or at [the doc](http://moonwave99.github.io/waffel/docs/), in order to get a better grasp on how can Waffel be useful to you.

---

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

Waffel doesn't know anything about your data schema. But as all the loaded data is exposed in the templates via the `data` property, you can deal with any sort of composition (e.g. `data.users[post.author]`). It is the price to pay for not having to write a schema, but I don't find it very expensive : ))

In case you really need a complex query mechanism, chances are that you need a different stack.

> Are there plugins? Is there a way to write any?

Writing a plugin for such a specific tool usually ends up in following a narrow DSL, with no real benefit on top of the hassle.  
You can include even complicate **filters** and **helpers**, that can be used all over the HTML template codes.

Nevertheless, have a look at the examples up here, they may help you to achieve your goal!

---

## License

The MIT License (MIT)

Copyright (c) 20015 Diego Caponera

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
