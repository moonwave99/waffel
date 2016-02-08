## Philosophy

**Waffel** was born as a simple script to generate [my website](http://www.diegocaponera.com/) and [another project of mine](http://www.shoegaze.it/), and eventually [my company's homepage](https://kreuzwerker.de). I thought it was worth releasing, basically because I plan to reuse it a lot in the close future, best as a companion to a content management tool I hope to release very soon.

I think that having a full web stack for a blog/portfolio/small business showcase site is really an overkill today: you need a lot of services running in order to serve content, you will be the very only one to change in a deterministic way.
Now that all our pathetic `comments.php` efforts have been teared apart by Disqus/social commenting facilities, why should we store our thoughts in a database, instead of on good ol' text files, editable in the way we find more comfortable?

### Why static at all

Since the early Nineties, when Internet (slowly) began becoming a common cultural phenomenon, experience was limited to navigate through [_hypertexts_](http://en.wikipedia.org/wiki/Hypertext) and see pictures (after several minutes, often) - no CSS, no buttons, almost no forms, no AJAX, no fancy interaction at all.

An hypertext was, is and will always be just **a graph of connected pages**, linked to other hypertexts on the web, all reachable via a browser.

After two decades of development and progress, we can build a business on top of geo-localisation and images taken via devices [more powerful that the NASA mainframe that routed the man on the Moon](http://www.phonearena.com/news/A-modern-smartphone-or-a-vintage-supercomputer-which-is-more-powerful_id57149).

But the Internet should stay a (huge) compendium of hypertexts, and the focus should stay on the content. Not on the comments, not on the "social" interaction, not in the twenty sidebars that clutter now your page.

Let's face it: if your website is content oriented, you don't care about how fancy the transition effect between pages may be - rather you want fast page loads and full control on the HTML response you deliver, no matter the way you access the page.

Write _good and accessible content_, and numbers will follow.

Development side note: you don't need a plugin for _everything_, I am really confident that you can set proper `<meta>`tags for your blogposts, or create thumbnails, or generate a sitemap. Some tasks are really easy to achieve on top of the existing (_cough_ npm _cough_) library ecosystem, yet require different fine tuning on project basis; consider wrapping it up yourself if you plan to reuse the feature a lot, but sometimes even a brief blogpost or a [gist](https://gist.github.com/) would do. Two lines of effectiveness are worth 50 lines of configurable options, if you know what I mean : ))

AND YOU CAN SYNC EASIER TO THE CLOUD IF YOU ARE STATIC, AND YOUR BOSS WILL BE HAPPY

### Markdown and Git/Github cover 99% of your needs.

On the sixth day God created [Frontpage](http://en.wikipedia.org/wiki/Microsoft_FrontPage), and that was bad. I don't know how many of you had their first contact with content management via the aforementioned program, still you can have a clue of the outcome by looking at the interface screenshots and the vendor name. You had to write raw HTML, and upload the outcome to your website via FTP. And the only way of using "templates" (i.e. reused chunks of code) was delegated to [`<framesets>`](http://en.wikipedia.org/wiki/Framing_%28World_Wide_Web%29).

Then the online **CMS** came: a jungle of dropdowns and buttons, that allowed secretaries to paste documents written in Word into a TinyMCE WYSIWIG textarea, that wrecked your valid HTML delivery intentions.

(_disclaimer_: nothing against mighty TinyMCE, I even [wrote a plugin for that](http://moonwave99.github.io/TinyMCELatexPlugin/) back then!)

That was the only way to publish content to the web - some attempts were good, and after many years of refinement we can now use dream platforms like [Medium](https://medium.com/) or [Ghost](https://ghost.org/).

---

But in a flow content context (like most of the content you deliver should be), do you really need WYSIWIG? Paragraphs are paragraphs, headers are headers, roses are red, violets are blue. Focus on the _hierarchy_ and _meaning_ of your content, and not on the alignment of your text (hint: should be left, at least in most western countries).

Markdown covers all your formatting needs, it is readable on its own, and it is the _de facto_ standard of the Good Web publishing. And in those corner cases that may not be covered by its syntax, you can place a couple of lines of raw HTML, or consider storing a property in the [YAML frontmatter](http://jekyllrb.com/docs/frontmatter/) in order to be used in a template.

Coming to Git/Github: pushing to a remote + using _post-receive_/_web_ hooks cover all publishing needs you would face. It is like **hitting the Save button**, with a couple seconds of delay, that would be widely saved among all future requests by the clients. Plus it is easier to revert, to keep track of the changes, to review work from other people.

I mean I would put my life under version control if I could:

    $ git checkout that-day-that-i-didnt-kiss-her-now-i-know-that-she-liked-me-but-lives-now-in-australia-with-mike-tyson --hard

Why shouldn't I wait doing it for the content of my website!

### Ok, so why then not _X.io_ or _Y.js_ ?

Believe me, I tried almost all generators out there: many of them are nice pieces of software, from whom I gathered a lot of useful ideas and inspiration, but they all either lacked some crucial featured that I needed, or were written in a language I am not really skilled in.

Moreover, I think that generating a set of `.html` files from a bunch of Markdown ones should be a task that any web developer should be able to accomplish in a couple of hours. So I stopped wandering on Github and wrote the `0.0.1` of Waffel.
