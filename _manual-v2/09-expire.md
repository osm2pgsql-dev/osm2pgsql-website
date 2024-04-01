---
chapter: 9
title: Expire
---

When osm2pgsql is processing OSM changes, it can create a list of (Web
Mercator) tiles that are affected by those changes. This list can later be used
to delete or re-render any changed tiles you might have cached. Osm2pgsql only
creates this list. How to actually expire the tiles is outside the scope of
osm2pgsql. Expire only makes sense in *append* mode.

Tile expiry will probably only work when creating Web Mercator (EPSG:3857)
geometries. When using other output projections osm2pgsql can still generate
expire files, but it is unclear how useful they are. The *flex* output will
only allow you to enable expire on Web Mercator geometry columns.
{:.note}

There are two ways to configure tile expiry. The old way (and the only way if
you are using the *pgsql* output) is to use the `-e, --expire-tiles`, `-o,
--expire-output`, and `--expire-bbox-size` command line options. This allows
only a single expire output to be defined (and it has to go to a file).

The new way, which is only available with the
*flex* output, allows you to define any number of expire outputs (and they can
go to files or to database tables).

### Expire Outputs

Each expire output has a minimum and maximum zoom level. For each geometry that
needs to be expired, the coordinates of the affected tiles are determined and
stored. When osm2pgsql is finished with its run, it writes the tile coordinates
for all zoom levels between minimum and maximum zoom level to the output.

There is a somewhat special case: If you don't define a zoom level for the
expire output, zoom level 0 is assumed for the minimum and maximum zoom level.
That means that *any* change will result in an expire entry for tile 0/0/0. You
can use this to trigger some processing for any and all changes in a certain
table for instance.

Memory requirements for osm2pgsql rise with the maximum zoom level used and the
number of changes processed. This is usually no problem for zoom level 12 or 14
tiles, but might be an issue if you expire on zoom level 18 and have lots of
changes to process.
{:.note}

The output can be written to a file or a table:

#### Expire File

The generated expire file is a text file that contains one tile coordinate per
line in the format `ZOOM/X/Y`. Tiles appear only once in the file even if
multiple geometry changes are affecting the same tile.

The file is written to in append mode, i.e. new tiles are added to the end of
the file. You have to clear the file after processing the tiles.

#### Expire Table

The expire table has five columns `zoom`, `x`, `y`, `first`, and `last`. A
primary key constraints on the first three columns makes sure that there is no
duplicate data. The `first` and `last` columns contain the timestamp of the
first time this tile was marked as expired and the last time, respectively.
These two timestamps can be used to implement various expiry strategies.

You have to delete entries from this file after expiry is run.

### Details of the Expire Calculations

To figure out which tiles need to be expired, osm2pgsql looks at the old and
new geometry of each changed feature and marks all tiles as expired that are
touched by either or both of those geometries. For new features, there is only
the new geometry, of course. For deleted features only the old geometry is
used.

If the geometry of a feature didn't change but the tags changed in some way
that will always trigger the expiry mechanism. It might well be that the tag
change does not result in any visible change to the map, but osm2pgsql can't
know that, so it always marks the tiles for expiry.

Which tiles are marked to be expired depends on the geometry type generated:

* For point geometries, the tile which contains this point is marked as
  expired.
* For line geometries (linestring or multilinestring) all tiles intersected
  by the line are marked as expired.
* For (multi)polygons there are several expire modes: In `full-area` mode
  all tiles in the bounding box of the polygon are marked as expired. In
  `boundary-only` mode only the lines along the boundary of the polygon are
  expired. In `hybrid` mode either can happen depending on the area of the
  polygon. Polygons with an area larger than `full_area_limit` are expired
  as if `boundary-only` is set, smaller areas in `full-area` mode. When using
  the *flex* output, you can set the `mode` and `full_area_limit` as needed
  for each geometry column. For the *pgsql* output the expire output always
  works in `hybrid` mode, use the `--expire-bbox-size` option to set the
  `full_area_limit` (default is 20000).

In each case neighboring tiles might also be marked as expired if the feature
is within a buffer of the tile boundary. This is so that larger icons, thick
lines, labels etc. which are rendered just at a tile boundary which "overflow"
into the next tile are handled correctly. By default that buffer is set at 10%
of the tile size, in the *flex* output it is possible to change it using the
`buffer` setting.

### Expire Command Line Options

These are the command line options to configure expiry. Use them with the
*pgsql* or *flex* output.

*Version >= 1.9.0*{:.version} When using the *flex* output it is recommended
you switch to the new way of defining the expire output explained in [Defining
and Using Expire Outputs](#defining-and-using-expire-outputs).

{% include_relative options/expire.md %}
