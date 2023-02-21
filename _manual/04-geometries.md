---
chapter: 4
title: Geometry Processing
---

An important part of what osm2pgsql does is creating geometries from OSM
data. In OSM only nodes have a location, ways get their geometry from member
nodes and relations get their geometry from member nodes and ways. Osm2pgsql
assembles all the data from the related objects into valid geometries.

### Geometry Types

The geometry types supported by PostGIS are from the [Simple
Features](https://en.wikipedia.org/wiki/Simple_Features){:.extlink} defined by
the OpenGIS Consortium (OGC). Osm2pgsql creates geometries of the following
types from OSM data:

| Geometry type      | Created from OSM data                                 |
| ------------------ | ----------------------------------------------------- |
| Point              | Created from nodes.                                   |
| LineString         | Created from ways.                                    |
| Polygon            | Created from closed ways or some relations.           |
| MultiPoint         | Created from nodes or some relations.                 |
| MultiLineString    | Created from (split up) ways or some relations.       |
| MultiPolygon       | Created from closed ways or some relations.           |
| GeometryCollection | *Version >= 1.7.0*{:.version} Created from relations. |
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
data, it can also lead to problems. [This
blogpost](https://www.paulnorman.ca/blog/2014/03/osm2pgsql-multipolygons/){:.extlink}
has some deeper discussion of this issue. See the flex and pgsql output
chapters for details on how to configure this. It will also mean that your id
columns are not unique, because there are now multiple rows created from the
same OSM object. See the [Primary Keys and Unique
IDs](#primary-keys-and-unique-ids) section for an option how to work around
this.

*Version >= 1.7.0*{:.version} When using the flex output, you can decide
yourself what geometries to create using the `as_point()`, `as_linestring()`,
`as_polygon()`, `as_multipoint()`, `as_multilinestring()`, `as_multipolygon()`,
and `as_geometrycollection()` functions. See the [Flex Output
chapter](#the-flex-output) for details.

### Geometry Validity

Point geometries are always valid (as long as the coordinates are inside the
correct range). LineString geometries are valid if they have at least two
distinct points. Osm2pgsql will collapse consecutive indentical points in a
linestring into a single point. Note that a line crossing itself is still valid
and not a problem.

Validity is more complex for Polygon and MultiPolygon geometries: There are
multiple ways how such a geometry can be invalid. For instance, if the boundary
of a polygon is drawn in a figure eight, the result will not be a valid
polygon. The database will happily store such invalid polygons, but this can
lead to problems later, when you try to draw them or do calculations based on
the invalid geometry (such as calculating the area).

You can use the [Areas view of the OpenStreetMap
inspector](https://tools.geofabrik.de/osmi/?view=areas){:.extlink} to help
diagnose problems with multipolygons.

Osm2pgsql makes sure that there are no invalid geometries in the database,
either by not importing them in the first place or by using an `ST_IsValid()`
check after import. You'll either get `NULL` in your geometry columns instead
or the row is not inserted at all (depending on config).

The `transform()` function in Lua config files projects a geometry into a
different SRS. In special cases this can make the geometry invalid, for
instance when two distinct points are projected onto the same point.
{:.note}

### Processing of Nodes

Node geometries are always converted into Point geometries.

### Processing of Ways

Depending on the tags, OSM ways model either a LineString or a Polygon, or
both! A way tagged with `highway=primary` is usually a linear feature, a way
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
chapter) how to configure this. Some of the example config files have lists
that should cover most of the commonly used tags, but you might have to extend
the lists if you are using more unusual tags.

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

*Version >= 1.7.0*{:.version} When using the flex output, you can decide
yourself what geometries to create from a way using the `as_linestring()`, or
`as_polygon()` functions. See the [Flex Output chapter](#the-flex-output) for
details.

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

*Version >= 1.7.0*{:.version} When using the [flex output](#the-flex-output),
you can decide yourself what geometries to create from a way using the
`as_multipoint()`, `as_multilinestring()`, or `as_multipolygon()` functions.
Also supported now is the `as_geometrycollection()` function which creates
GeometryCollection from all member nodes and ways of a relation (relation
members are ignored).

If you are using the old "C transform" of the pgsql output, the geometry types
for relations of type `multipolygon`, `boundary`, and `route` are hardcoded. If
you are using the "Lua transform" of the pgsql output you can configure
them somewhat.

Note that osm2pgsql will ignore the roles (`inner` and `outer`) on multipolygon
and boundary relations when assembling multipolygons, because the roles are
sometimes wrong or missing.

### Handling of Incomplete OSM Data

Sometimes you will feed incomplete OSM data to osm2pgsql. Most often this will
happen when you use [geographical extracts](#geographical-extracts), either
data you downloaded from somewhere or [created yourself](
#creating-geographical-extracts). Incomplete data, in this case, means that
some member nodes of ways or members of relations are missing. Often this can
not be avoided when creating an extract, you just have to put that cut somewhere.

When osm2pgsql encounters incomplete OSM data it will still try to do its
best to use it. Ways missing some nodes will be shortened to the available
part. Multipolygons might be missing some parts. In most cases this will
work well (if your extract has been created with a sufficiently large buffer),
but sometimes this will lead to wrong results. In the worst case, if a
complete outer ring of a multipolygon is missing, the multipolygon will
appear "inverted", with outer and inner rings switching their roles.

Unfortunately there isn't much that osm2pgsql (or anybody) can do to improve
this, this is just the nature of OSM data.

### Projections

Osm2pgsql can create geometries in many projections. If you are using the
pgsql output, the projection can be chosen with command line options. When
using the flex output, the projections are specified in the Lua style file.
The default is always "Web Mercator".

*Version >= 1.7.0*{:.version} When using the flex output, osm2pgsql will
usually magically transform any geometry you are writing into a database table
into the projection you defined your tables with. But you can use the
`transform()` function on the geometry to force a certain transformation. This
is useful, for instance, if you want to calculate the area of a polygon in a
specific projection. See the [Flex Output chapter](#the-flex-output) for
details.

<table class="proj"><tr><td>
<img alt="" src="{% link img/plate-carree.jpg %}" title="Equirectangular projection. Image source: Wikipedia (https://en.wikipedia.org/wiki/File:Equirectangular_projection_SW.jpg)"/>
</td><td markdown="1">

#### Latlong (WGS84)

[EPSG:4326](https://epsg.io/4326){:.extlink}

The original latitude & longitude coordinates from OpenStreetMap in the WGS84
coordinate reference system. This is typically chosen if you want to do some
kind of analytics on the data or reproject it later.

</td></tr><tr><td>
<img alt="" width="128" src="{% link img/web-mercator.jpg %}" title="Mercator projection. Image source: Wikipedia (https://en.wikipedia.org/wiki/File:Mercator_projection_Square.JPG)"/>
</td><td markdown="1">

#### Web Mercator

[EPSG:3857](https://epsg.io/3857){:.extlink}

This is the projection used most often for tiled web maps. It is the default
in osm2pgsql.

Data beyond about 85° North and South will be cut off, because it can not be
represented in this projection.

</td></tr><tr><td>
<img alt="" width="128" src="{% link img/mollweide.png %}" title="Mollweide Projection. Image source: Wikipedia (https://en.wikipedia.org/wiki/File:Mollweide_projection_SW.jpg)"/>
</td><td markdown="1">

#### Other Projections

If osm2pgsql was compiled with support for the [PROJ
library](https://proj.org/){:.extlink}, it supports all projections supported
by that library.

*Version >= 1.4.0*{:.version} Call `osm2pgsql --version` to see whether your
binary was compiled with PROJ and with which version.

</td></tr></table>

Note that mapping styles often depend on the projection used. Most mapping
style configurations will enable or disable certain rendering styles depending
on the map scale or zoom level. But a meaningful scale will depend on the
projection. Most styles you encounter are probably made for Web Mercator
and will need to be changed if you want to use them for other projections.

