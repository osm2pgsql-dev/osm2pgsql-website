---
chapter: 4
title: Geometry Processing
---

An important part of what osm2pgsql does is creating geometries from OSM
data. In OSM only nodes have a location, ways get their geometry from member
nodes and relations get their geometry from member ways and nodes. Osm2pgsql
assembles all the data from the related objects into valid geometries.

### Geometry Types

The geometry types supported by PostGIS are from the [Simple
Features](https://en.wikipedia.org/wiki/Simple_Features){:.extlink} defined by
the OpenGIS Consortium (OGC). Osm2pgsql creates geometries of these types
from OSM data.

| Geometry type   | Created from OSM data                           |
| --------------- | ----------------------------------------------- |
| Point           | Created from nodes.                             |
| LineString      | Created from ways.                              |
| Polygon         | Created from closed ways or some relations.     |
| MultiPoint      | Never created.                                  |
| MultiLineString | Created from (split up) ways or some relations. |
| MultiPolygon    | Created from closed ways or some relations.     |
{: .desc}

### Single vs. Multi Geometries

Generally osm2pgsql will create the simplest geometry it can. Nodes will turn
into Points, ways into LineStrings or Polygons. A multipolygon relation can be
turned into a Polygon or MultiPolygon, depending on whether it has one or more
outer rings. Similarly, a route relation can be turned into a LineString if
the route is connected from start to finish or a MultiLineString if it is
unconnected or there are places, where the route splits up.

In some cases osm2pgsql will split up Multi\* geometries into simple geometries
and add each one in its own database row. This can make rendering faster,
because the renderer can deal with several smaller geometries instead of having
to handle one large geometry. But, depending on what you are doing with the
data, in can also lead to problems. [This
blogpost](http://www.paulnorman.ca/blog/2014/03/osm2pgsql-multipolygons/){:.extlink}
has some deeper discussion of this issue. See the flex and pgsql output
chapters for details how to configure this.

It will also mean that your id columns are not unique, because there are now
multiple rows created from the same OSM object. See the [Primary Keys and
Unique IDs](#primary-keys-and-unique-ids) section for an option how to work
around this.

### Geometry Validity

Point geometries are always valid (as long as the coordinates are inside the
correct range). LineString geometries are also always valid, lines might cross
themselves, but that is okay. This is more complex for Polygon and MultiPolygon
geometries: There are multiple ways how such a geometry can be invalid. For
instance, if the boundary of a polygon is drawn in a figure eight, the result
will not be a valid polygon. The database will happily store such invalid
polygons, but this can lead to problems later, when you try to draw them or do
calculations (such as the area) based on the invalid geometry. That's why
osm2pgsql never loads invalid geometries into your database. Instead the object
is simply ignored without any message.

You can use the [Areas view of the OpenStreetMap
inspector](https://tools.geofabrik.de/osmi/?view=areas){:.extlink} to help
diagnose problems with multipolygons.

### Processing of Nodes

Node geometries are always converted into Point geometries.

### Processing of Ways

Depending on the tags, OSM ways model either a LineString or a Polygon, or
both! A way tagged with `highway=primary` is usally a linear feature, a way
tagged `landuse=farmland` is usually a polygon feature. If a way with polygon
type tags is not closed, the geometry is invalid, this is an error and the
object is ignored. For some tags, like `man_made=pier` non-closed ways are
linear features and closed ways are polygon features.

If a mapper wants to override how a way should be interpreted, they can use the
`area` tag: The tag `area=yes` turns a normally linear feature into a polygon
feature, for instance it turns a pedestrian street (`highway=pedestrian`) into
a pedestrian area. The tag `area=no` turns a polygon feature into a linear
feature.

There is no definite list which tags indicate a linear or polygon feature.
Osm2pgsql lets the user decide. It depends on your chosen output (see next
chapter) how to configure this. The example config files have lists that should
cover most of the commonly used tags, but you might have to extend the lists if
you are using more unusal tags.

Osm2pgsql can split up long LineStrings created from ways into smaller
segments. This can make rendering of tiles faster, because smaller geometries
need to be retrieved from the database when rendering a specific tile. The
pgsql output always splits up long LineStrings, in latlong projection, lines
will not be longer than 1°, in Web Mercator lines will not be longer than
100,000 units (about 100,000 meters at the equator). The flex output will only
split LineStrings if the `split_at` transformation parameter is used, see the
[Geometry transformations](#geometry-transformations) section in the flex
output chapter for details. See also the [Single vs. Multi
Geometries](#single-vs-multi-geometries) section above.

### Processing of Relations

Relations come in many variations and they can be used for all sorts of
geometries. Usually it depends on the `type` tag of a relation what kind of
geometry it should have:

| Relation type     | Typical geometry created  |
| ----------------- | ------------------------- |
| type=multipolygon | (Multi)Polygon            |
| type=boundary     | (Multi)LineString or (Multi)Polygon depending on whether you are interested in the boundary itself or the area it encloses. |
| type=route        | (Multi)LineString         |
{: .desc}

The osm2pgsql flex output can create a (Multi)Polygon or (Multi)LineString
geometry from any relation, other geometries are currently not supported. See
the [Geometry transformations](#geometry-transformations) section in the flex
output chapter for details.

If you are using the old "C transform" of the pgsql output, the geometry
types for relations of type `multipolygon`, `boundary`, and `route` are
hardcoded. If you are using the "Lua transform" you can configure them.

### Projections

Osm2pgsql can create geometries in many projections. If you are using the
pgsql output, the projection can be chosen with command line options, when
using the flex output, the projections are specified in the Lua style file.
The default is always "Web Mercator".

<table class="proj"><tr><td>
<a href="https://en.wikipedia.org/wiki/File:Equirectangular_projection_SW.jpg"><img src="{% link img/plate-carree.jpg %}"/></a>
</td><td markdown="1">

#### Latlong (WGS84)

[EPSG:4326](https://epsg.io/4326){:.extlink}

The original latitude & longitude coordinates from OpenStreetMap in the WGS84
coordinate reference system. This is typically chosen if you want to do some
kind of analytics on the data or reproject it later.

</td></tr><tr><td>
<a href="https://en.wikipedia.org/wiki/File:Mercator_projection_Square.JPG"><img width="128" src="{% link img/web-mercator.jpg %}"/></a>
</td><td markdown="1">

#### Web Mercator

[EPSG:3857](https://epsg.io/3857){:.extlink}

This is the projection used most often for tiled web maps. It is the default
in osm2pgsql.

Data beyond about 85° North and South will be cut off, because it can not be
represented in this projection.

</td></tr><tr><td>
<a href="https://en.wikipedia.org/wiki/File:Mollweide_projection_SW.jpg"><img width="128" src="{% link img/mollweide.png %}"/></a>
</td><td markdown="1">

#### Other Projections

If osm2pgsql was compiled with support for the [PROJ
library](https://proj.org/){:.extlink}, it supports all projections supported
by that library.

</td></tr></table>

Note that mapping styles often depend on the projection used. Most mapping
style configurations will enable or disable certain rendering styles depending
on the map scale or zoom level. But a meaningful scale will depend on the
projection. Most styles you encounter are probably made for Web Mercator
and will need changes to get nice maps in other projections.

