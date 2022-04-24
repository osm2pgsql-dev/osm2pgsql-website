
# Website osm2pgsql.org

This is the source code for the website of the osm2pgsql software at
[osm2pgsql.org](https://osm2pgsql.org).

It is written using the static web site generator
[Jekyll](https://jekyllrb.com/).

To run it locally, you need Ruby. Then check out the repository and install
Jekyll:

```
git clone https://github.com/openstreetmap/osm2pgsql-website
cd osm2pgsql-website
gem install bundler jekyll
touch contact.md
bundle exec jekyll serve
```

You'll then have a local version running on `http://127.0.0.1:4000/`.

Read https://osm2pgsql.org/contribute/ for more about helping out.

## Manpages

To create the osm2pgsql-replication man page call (in the osm2pgsql repo):

```
groff -mandoc -Thtml docs/osm2pgsql-replication.1
```

Copy the result into a page similar to `doc/man/osm2pgsql-replication-1.6.0.md`
and add a link to `doc/man/index.md`.

