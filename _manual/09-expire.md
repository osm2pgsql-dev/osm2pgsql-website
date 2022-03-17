---
chapter: 9
title: Expire
---

When osm2pgsql is processing OSM changes, it can create a list of (web
mercator) tiles that are affected by those changes. This list can later be used
to delete or re-render any changed tiles you might have cached. Osm2pgsql only
creates this list. How to actually expire the tiles is outside the scope of
osm2pgsql. Expire only makes sense in *append* mode.

Tile expiry will probably only work when creating web mercator (EPSG:3857)
geometries. When using other output projections osm2pgsql can still generate
expire files, but it is unclear how useful they are.
{:.note}

Tile expiry is only enabled if the `-e, --expire-tiles` option is set to
anything but `0`. Use this option to set the zoom level(s) which should be
used for tile expiry. Details are below.

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
* For (multi)polygons all tiles in the bounding box are marked as expired.
  If the (multi)polygon is too large, only the boundary of the (multi)polygon
  is expired as described for line geometries above. "too large" in this
  case means with a bounding box of greater width or height (in meters) than
  what's set with the `--expire-bbox-size` option (default is 20000).

In each case neighboring tiles might also be marked as expired if the feature
is within a buffer of the tile boundary. This is so that larger icons, thick
lines, labels etc. which are rendered just at a tile boundary which "overflow"
into the next tile are handled correctly. Currently that buffer is set at 10%
of the tile size, it is not possible to change it.

### The Expire File

The list of tiles to be expired is written to a file. The name is specified
with the `-o, --expire-output=FILENAME` option, it defaults to `dirty_tiles`
in the current directory.

The generated expire file is a text file that contains one tile descriptor per
line in the format `ZOOM/X/Y`. Tiles appear only once in the file even if
multiple geometry changes are affecting the same tile.

If you set the `-e, --expire-tiles` option to a single zoom level, for instance
`--expire-tiles=12` then all tiles in the expire tile have that zoom level. If
you set the option to a range of zoom levels, for instance `-e 10-14`, the file
contains the tiles in all those zoom levels.

Memory requirements for osm2pgsql rise with the maximum zoom level used and the
number of changes processed. This is usually no problem for zoom level 12 or 14
tiles, but might be an issue if you expire on zoom level 18 and have lots of
changes to process.
{:.note}

{% include_relative options/expire.md %}
