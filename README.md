
# Website osm2pgsql.org

This is the source code for the website of the osm2pgsql software at
[osm2pgsql.org](https://osm2pgsql.org).

It is written using the static web site generator
[Jekyll](https://jekyllrb.com/).

## Development

The code is expected to be run on stable Debian using ruby packages from
the distribution. To install the required packages run:

```
sudo apt install ruby ruby-bundler jekyll jekyll-theme-minima \
                 ruby-kramdown-parser-gfm ruby-jekyll-feed \
                 ruby-jekyll-last-modified-at
```

Then check out the repository and build the site:

```
git clone https://github.com/osm2pgsql-dev/osm2pgsql-website
cd osm2pgsql-website
touch contact.md
bundle exec jekyll serve
```

You'll then have a local version running on `http://127.0.0.1:4000/`.

You can also install the ruby packages from gems. Simply run
`gem install bundler jekyll && bundle install` after checking out the code.
Please make sure to not submit any accidental changes to the `Gemfile.lock`
file in PRs, if you compile this way.

## Contributing

Read https://osm2pgsql.org/contribute/ for more about helping out.

## Manpages

To create the osm2pgsql-replication man page call (in the osm2pgsql repo):

```
groff -mandoc -Thtml man/osm2pgsql-replication.1
```

Copy the result into a page similar to `doc/man/osm2pgsql-replication-1.6.0.md`
and add a link to `doc/man/index.md`.

