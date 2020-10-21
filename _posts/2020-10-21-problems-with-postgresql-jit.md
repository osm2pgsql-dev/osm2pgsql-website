---
layout: post
title: Problems with PostgreSQL JIT
---

Since version 11 PostgreSQL can use [Just-in-Time Compilation
(JIT)](https://www.postgresql.org/docs/current/jit.html) to speed up
processing. But unfortunately using JIT can make osm2pgsql slower.

If JIT is enabled, there is a problem in how the query planner in PostgreSQL
handles certain queries from osm2pgsql leading to massive slowdowns. This is
only a problem for updates, initial imports are fine. On PostgreSQL 11 JIT is
still disabled by default, so you are not likely to see it there, but since
version 12 JIT is usually enabled. The problem was [noticed and
diagnosed](https://github.com/openstreetmap/osm2pgsql/issues/1045) and we added
code in release 1.3.0 that was supposed to disable JIT in PostgreSQL for our
database connections. Unfortunately this code had a bug and JIT was never
disabled.

The next release will have a fix for this, but in the mean time the
recommendation is to manually disable JIT when running osm2pgsql. You can
either do this by setting these in your PostgreSQL config:

```
jit = off
max_parallel_workers_per_gather = 0
```

Or, if you only want to disable this when running osm2pgsql, set the
environment variable `PGOPTIONS` before calling osm2pgsql with something
like this:

```
export PGOPTIONS="-c jit=off -c max_parallel_workers_per_gather=0"
```

