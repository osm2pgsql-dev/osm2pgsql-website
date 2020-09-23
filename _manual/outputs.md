---
chapter: 4
title: Outputs
---

Osm2pgsql imports OSM data into a PostgreSQL database. *How* it does this
is governed by the *output* (sometimes called a *backend*). Several outputs
for different use cases are available.

### The *flex* Output

This is the most modern and most flexible output option. If you are starting
a new project, use this output. Many future improvements to osm2pgsql will
only be available in this output.

Unlike all the other options here there is almost no limit to how the OSM data
should be imported into the database. You can decide which OSM objects should
be written to which columns in which database tables. And you can define any
transformations to the data you need, for instance to unify a complex tagging
schema into a simpler schema if that's enough for your use case.

### The *pgsql* Output

The *pgsql* output is the original output and the one that most people who
have been using osm2pgsql know about. Many tutorials you find on the Internet
only describe this output. It is quite limited in how the data can be
written to the database, but many setups still use it.

This output comes in two "flavours": With the original "C transformation"
and with the somewhat newer "Lua transformation".

### The *gazetteer* Output

The *gazetteer* output is a specialized output used for
[Nominatim](https://nominatim.org/) only. See the Nominatim documentation
for its use.

### The *multi* Output

The *multi* output is deprecated, it will be removed in a future version of
osm2pgsql. If you are using it, switch to the flex output as soon as possible.

### The *null* Output

The *null* output doesn't write the data anywhere. It is used for testing and
benchmarking, not for normal operation.

