---
title: Other OSM-Databases
layout: coda
---

As part of this project we looked at some existing OSM databases. Some of these
solve similar problems, some have different use cases.

The most similar is Imposm3 which basically addresses the same use case as
osm2pgsql, it gets [its own page]({% link project-coda/imposm.md %}). Some
other applications are described below.

Multiple solutions implement various tricks first used in the [OSM PBF file
format](https://wiki.openstreetmap.org/wiki/PBF_Format){:.extlink} and also
employed by typical general-purpose column-oriented database formats: Storing
of similar data together in blocks, using delta- and varint-encoding of numbers
and dictionaries for strings. Also sometimes used is a second-stage compressing
the already encoded blocks with a general-purpose compression algorithm to make
them even smaller.

## Overpass API

[Overpass API](https://wiki.openstreetmap.org/wiki/Overpass_API){:.extlink} has
been around for some time. It is a completely from-scratch implementation of a
database specialized for OSM data not using any underlying database. It comes
with a complex bespoke query language that allows querying OSM data by geometry
as well as by tags and in many other forms. It even supports querying historic
OSM data. This means it has a very complex structure with many specialized
indexes. Its code is very dense and hard to understand and the resulting
database is ultimately rather larger than what we want to achieve (~ 400 GByte
for a planet database).

## OSM Express

At first glance the [OSM Express (osmx)
database](https://github.com/bdon/OSMExpress){:.extlink} seems to be exactly
what we need, a raw storage of OSM data that can be updated and contains
indexes to get from members to their parent objects. But the [on-disk storage
format](https://github.com/bdon/OSMExpress/blob/main/docs/MANUAL.md){:.extlink}
is very verbose, so it goes counter to what we want. A 4.3 GiB extract is
turned into 58 GiB of osmx database, more than 13 times larger.

The manual says:

*"As of 2019, fast local storage is cheap; 1 terabyte solid state drives are
less than 150 USD. On managed hosting providers like AWS and Google Cloud,
extra storage is affordable compared to more memory or CPU cores."*

And further:

*"If it's necessary to optimize for storage space, an .osmx file can be stored
on a filesystem with transparent compression such as ZFS or Btrfs, at the cost
of CPU overhead. This can reduce planet.osmx to around 200GB."*

That usage still means there is a lot of expensive IO plus extra CPU overhead
and more complex use, because of the need for file systems that do compression.
And while it looked for a while like disk space would get cheaper ever and
ever, that isn't the case any more.

What's interesting is their use of
[LMDB](https://symas.com/lmdb.php){:.extlink} which allows the database to be
in a single file.

## Geodesk

The [Geodesk](https://docs.geodesk.com/){:.extlink} code and formats are quite
complex. [This community forum
thread](https://community.openstreetmap.org/t/new-osm-file-format-30-smaller-than-pbf-5x-faster-to-import/137151){:.extlink}
contains some information. It uses some clever techniques, but its not clear
how applicable they are for our needs, because updates are (currently) not
possible with that format.

Geodesk is quite a different application than osm2pgsql and so its database
format "GOL" (Geographic Object Library) and the related "GOB" format store
different data than what we need.

Data is split by its location into "tiles" in several zoom levels. Geometries
for ways are pre-built, member nodes are stored as Id if they have tags, but
just the location is stored if the node doesn't have any tags. Attributes are
never stored.

The documentation and some blog posts of Geodesk mention that updates are
supported or are planned, but there currently seems no way to do them. But
updates are at the core of what the osm2pgsql middle must support.

Geodesk stores strings (keys/values/roles) using a dictionary. A global string
dictionary with at most 2<sup>32</sup> of the most common strings (but usually
much less) is generated on import, but that needs two passes through the data
to find often used strings. Not so common strings are stored in a per-tile
dictionary.

And it uses another trick: If two objects have the exact same tags, it can
somehow store that only once and point to it from the objects. This is
reasonably easy to implement for a store that's never updates, but would add
quite some complexity for an updateable database. I did some [statistics on
common tags used together]({% link project-coda/tag-combinations.md %}) to find
out how much this could help.

