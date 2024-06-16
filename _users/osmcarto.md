---
title: OpenStreetMap Carto
order: 1
links:
    - href: https://www.openstreetmap.org/
      title: www.openstreetmap.org
    - href: https://switch2osm.org/serving-tiles/
      title: Switch2OSM
    - href: https://github.com/gravitystorm/openstreetmap-carto
      title: OSM Carto
tags:
    - raster map
    - open source
---

This is the original use case for osm2pgsql: Supporting the raster map at
www.openstreetmap.org. The OSM Foundations runs a bunch of servers generating
and distributing the most iconic OSM map called "OpenStreetMap Carto". And
osm2pgsql makes sure this map is updated, usually within minutes of changes
being applied to the OSM database.

If you want to install such a map yourself, have a look at Switch2OSM and OSM
Carto. By the way: You don't have to use the same map style, there are other
styles around that use the same database layout.
