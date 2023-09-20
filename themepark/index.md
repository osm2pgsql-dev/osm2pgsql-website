---
title: Themepark
---

# Themepark

Writing a config file for osm2pgsql from scratch is not easy. And it shouldn't
be something that everybody has to do. Most maps want to do *some* things
different than other maps, but *most* things are probably the same as on many
other maps. **Themepark** is a framework for creating osm2pgsql configuration
by reusing existing building blocks. You can mix existing configurations with
your special layers. And it all works together.

Themepark is written in Lua, like all osm2pgsql flex config files. You don't
need anything beyond osm2pgsql except the [Git
repository](https://github.com/osm2pgsql-dev/osm2pgsql-themepark).

**Themepark is currently in BETA test. It already works quite well, but we'll
probably change some things around when we have some more experience with it.**
Go to the [*Themepark* discussion category in the osm2pgsql
repository](https://github.com/osm2pgsql-dev/osm2pgsql/discussions/categories/themepark)
to ask questions or discuss anything related to Themepark.
{:.note}

## Themepark Concepts

Here are some important Themepark concepts. Themepark builds on the osm2pgsql
Lua flex config files, so all the concepts from there still apply.

**Topics:** Instead of having one large config file with the configuration for
all the layers, Themepark configs consist of a small config file that includes
several *topics*. *Topics* are usually one or more layers that belong together,
so you might have a "water" topic that includes a polygon layer for lakes etc.
and a linestring layer for rivers etc.

**Themes:** Topics are organized in *themes*. A *theme* can bring together
several topics that work well together or that have something else in common.
Some themes are defined in the [Themepark
repository](https://github.com/osm2pgsql-dev/osm2pgsql-themepark), others can
be provided by third parties, or you can write your own.

**Plugins:** Themepark *plugins* can do some extra processing beyond the
processing of OSM data. They can be used, for instance, to generate a config
file for a tileserver. You can use existing plugins or write your own.

## Features

* You can have several configurations at the same time to support different
  styles etc.
* Plugins for extra functionality: Create tile server config files.
* Works with the experimental generalization support in osm2pgsql to
  automatically generate tables for low zoom levels when OSM data changes.
* Sensible defaults with the flexibility to overwrite them if needed.
* Set policy for naming features based on various OSM tags in one place and
  use for all layers.
* Includes support for external layers (such as coastlines).

## Manuals

Read the [**Themepark Users Manual**]({% link themepark/users-manual.md %}) if
you want to use (and possibly modify) a configuration based on Themepark for
your map.

Read the [**Themepark Authors Manual**]({% link themepark/authors-manual.md %})
if you want to write your own Themepark themes.

## Examples

See the [example config
directory](https://github.com/osm2pgsql-dev/osm2pgsql-themepark/tree/master/config)
for some configs to start with.

