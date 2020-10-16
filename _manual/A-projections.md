---
chapter: 20
appendix: A
title: Projections
---

Osm2pgsql can create geometries in many projections. If you are using the
pgsql output, the projection can be chosen with command line options, when
using the flex output, the projections are specified in the Lua style file.
The default is always "Web Mercator".

<table style="border-spacing: 10px;"><tr><td>
<a href="https://en.wikipedia.org/wiki/File:Equirectangular_projection_SW.jpg"><img width="128" src="{% link img/plate-carree.jpg %}"/></a>
</td><td markdown="1">

### Latlong (WGS84)

[EPSG:4326](https://epsg.io/4326){:.extlink}

The original latitude & longitude coordinates from OpenStreetMap in the WGS84
coordinate reference system. This is typically chosen if you want to do some
kind of analytics on the data or reproject it later.

</td></tr><tr><td>
<a href="https://en.wikipedia.org/wiki/File:Mercator_projection_Square.JPG"><img width="128" src="{% link img/web-mercator.jpg %}"/></a>
</td><td markdown="1">

### Web Mercator

[EPSG:3857](https://epsg.io/3857){:.extlink}

This is the projection used most often for tiled web maps. It is the default
in osm2pgsql.

Data beyond about 85° North and South will be cut off, because it can not be
represented in this projection.

</td></tr><tr><td>
<a href="https://en.wikipedia.org/wiki/File:Mollweide_projection_SW.jpg"><img width="128" src="{% link img/mollweide.png %}"/></a>
</td><td markdown="1">

### Other Projections

If osm2pgsql was compiled with support for the [PROJ
library](https://proj.org/){:.extlink}, it supports all projections supported
by that library.

</td></tr></table>
