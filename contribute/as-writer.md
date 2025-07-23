---
title: Contribute Documentation
---

# Contribute Documentation

Documentation is not just something for experts.
Whether you are a developer, a style writer or a simple user of osm2pgsql,
your unique perspective helps to make the documentation more readable for
the next person.

Most of our documentation lives on the website of osm2pgsql.org.
There are three sections, which would particularly benefit from your
contributions: the manual, usage examples and tutorials

You find the source code for the documentation in the
[osm2pgsql-website repo](https://github.com/osm2pgsql-dev/osm2pgsql-website){:.extlink}.
For smaller changes it is perfectly fine to use the built-in Github
editor directly and propose your changes as pull request. Maintainers will then
make sure that everything looks still correct before merging.

## User Manual

The [User manual]({% link doc/manual.html %}) is the handbook that explains
all of osm2pgsql's functionality in detail. Every configuration option
should be featured in the manual. Some sections are still quite compact
at the moment. If you had trouble understanding the manual, give it a
shot at making it better for the next reader.

## Usage Examples

[Usage examples]({% link examples/index.md %}) show-case the versatility
of osm2pgsql and should give users are starting point from which they can
realise their own projects. A good example is self-contained with a short
and easily understandable configuration and preferably a nice picture to
show the outcome.

#### Flex Examples

A lot of the examples for the flex output currently live in the
[flex-config](https://github.com/osm2pgsql-dev/osm2pgsql/tree/master/flex-config){:.extlink}
directory in the osm2pgsql source. That's because these examples are older than
the osm2pgsql website. We'd like to integrate the examples with the rest of the
documentation at some point. How this can work, is not quite clear yet.
They could possibly be the base for an extensive tutorial section. Contributions
in that direction are welcome. In the meantime, it is also okay to propose new
examples in the old place. Have a look at the
[README file](https://github.com/osm2pgsql-dev/osm2pgsql/blob/master/flex-config/README.md){:.extlink}
to understand the structure of the examples.

## Tutorials

[Tutorials]({% link doc/tutorials/index.md %}) are meant to be longer
step-by-step explanations to learn to understand certain aspects of osm2pgsql.
We don't have any good tutorials yet but certainly would like them. Anything
from a beginner's introduction to flex to a guide to the complex internals of
expiry is possible.

## External Blogs

We also have a section featuring 
[external blog posts and tutorials on osm2pgsql]({% link doc/community.md %}).
