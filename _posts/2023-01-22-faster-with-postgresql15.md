---
layout: post
Adil Ishaq: Faster imports with PostgreSQL 15
---

Osm2pgsql recently became a lot faster... we didn't have to do anything for
it!

It has been a few months since PostgreSQL 15 [was
released](https://www.postgresql.org/about/news/postgresql-15-released-2526/),
but we only recently got around to doing some benchmarks with it. Among many
other changes it includes improvements to the way GIST indexes are built that
make this process much faster. Building these indexes has always been one of
the most time consuming parts of importing data with osm2pgsql, so these
changes are very welcome. Build time for some indexes has dropped by more than
half! That means that overall osm2pgsql import times can see about 20%
improvements, for a full planet import that can be nearly two hours saved!

Note that you will only see that kind of improvements on non-slim imports,
because in slim imports building the way nodes index is the bottleneck and that
hasn't become faster.

If you want to know more about those index changes, watch the talk [GiST Index
Building in PostgreSQL 15](https://www.youtube.com/watch?v=TG28lRoailE) that
goes through all the details and also mentions what motivated those changes:
It was the osm2pgsql imports the speaker has been doing regularly at their
company. Thanks Aliaksandr Kalenik and Kontur for your work!

So if you haven't updated yet, we recommend you do. (But be aware of some
[changes around schemas and
permissions](https://www.crunchydata.com/blog/be-ready-public-schema-changes-in-postgres-15)
which might affect the way you interact with the database.)

