---
layout: post
title: Announcing Themepark
---

Writing a config file for osm2pgsql from scratch is not easy. And it shouldn't
be something that everybody has to do. Most maps want to do *some* things
different than other maps, but *most* things are probably the same as on many
other maps. [Themepark](https://osm2pgsql.org/themepark) is a framework for
creating osm2pgsql configuration by reusing existing building blocks. You can
mix existing configurations with your special layers. And it all works
together.

Today we are releasing a beta version of Themepark. It is still somewhat rough
around the edges, but you can play with it and together we'll make it better.
It comes with various more or less experimental themes to get you some ideas.

It also comes with the configuration to generate vector tiles using the
[Shortbread schema](https://shortbread-tiles.org/). There are two versions, one
without generalization which is really only usable on high zoom levels (12 and
above or so) and one using the new experimental generalization support in
osm2pgsql which can be used as basis for complete vector tile set on all zoom
levels.

We thank [Sourcepole](https://sourcepole.ch/) for funding part of the work on
the Shortbread configuration.

You'll find more details at on the [Themepark page on
osm2pgsql.org](https://osm2pgsql.org/themepark), the code is [on
Github](https://github.com/osm2pgsql-dev/osm2pgsql-themepark).

