---
title: Contribute
---

# Contribute

Osm2pgsql is an Open Source project. Your contributions are welcome. You can
find the source code and issue tracker on
[Github](https://github.com/openstreetmap/osm2pgsql){:.extlink}. For some
starting points see the
[contribute page](https://github.com/openstreetmap/osm2pgsql/contribute).

Please see [CONTRIBUTING.md](https://github.com/openstreetmap/osm2pgsql/blob/master/CONTRIBUTING.md)
for some information about how to contribute.

There is a kind of [road map]({% link contribute/road-map.md %}) for osm2pgsql
development. It’s not to be understood as a definite “this is what we’ll do”
document, but as a rough and incomplete overview of the shared understanding of
the maintainers about where we are and in what areas we see need for work.

See also the [generalization project]({% link generalization/index.md %}).

<section markdown="1">
## Tests and Continuous Integration

[![Github Actions Build Status](https://github.com/openstreetmap/osm2pgsql/workflows/CI/badge.svg?branch=master)](https://github.com/openstreetmap/osm2pgsql/actions)

We have a growing suite of tests, new features and bug fixes should always
have test coverage.

The `master` branch and all pull requests are checked automatically using
Github Actions (on Linux, macOS and Windows).

</section>

<section markdown="1">
## Compatibility

We strive to be out-of-the-box compatible with major Linux distributions to
make use of osm2pgsql as easy as possible for many users. Usually at least
the last long-term release of the major Linux distributions is supported.
This [handy list of dependencies]({% link contribute/dependencies.md %})
helps with that.

We strive to support all versions of PostgreSQL and PostGIS that are

* available in the Linux distributions we support, and
* are supported upstream (i.e. from the PostgreSQL and PostGIS teams).

</section>

<section markdown="1">
## License

The software *osm2pgsql* is available under the [GNU General Public
License](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html){:.extlink}.
</section>

<section markdown="1">
## Contributing to this Website

This website (osm2pgsql.org) is hosted on
[Github](https://github.com/openstreetmap/osm2pgsql-website){:.extlink}. We
welcome contributions to it. Please open an issue, or even better, a pull
request with your changes.

Most pages on this website have an "Source of this page" link at the bottom
that will take you right to the Github repository page. Each section in the
manual has a little ✎ (pencil) button for the same use.
</section>
