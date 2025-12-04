---
layout: post
title: Test Your Styles with the New Style Tester
---

Styles (configurations) for osm2pgsql are written in the Lua programming
language. And they are becoming more complex. Users have been asking for a long
time for some way of testing those styles to help with writing and debugging
the Lua code. We now have a solution for you.

We have had tests for osm2pgsql, the software, for a long time. This includes
tests that run osm2pgsql with certain inputs and parameters and check that
osm2pgsql produces the correct output, including checks that make sure the
correct information ends up in the correct database tables. These kinds of
tests are really similar to what users need, but the tests were deeply
integrated with the rest of the osm2pgsql testing system, they were hard to
use, and they were not documented.

We have polished that testing framework, documented it and made it work on its
own and are now making it available for osm2pgsql users. So you can now use the
same testing engine used for internal testing to test your style sheets. The
test code builds upon the Python BDD [behave](https://behave.readthedocs.io/)
testing framework, and adds all sorts of useful features to the tests. OSM test
data can be integrated in various ways, inline in the test file or as external
data. And we have added various handy features for testing database content.

Style testing will be available in the next version of osm2pgsql, but you can
already try it out. You only need to download a [single
file](https://github.com/osm2pgsql-dev/osm2pgsql/blob/master/scripts/osm2pgsql-test-style)
from the current master and can use that with any reasonably modern version
of osm2pgsql. Find the full documentation in [the
manual](https://osm2pgsql.org/doc/manual.html#style-testing).

We'd love it if you tried the new style tester and tell us what you think. We
are sure there will be some teething problems you can help us find and fix
before the next release.

