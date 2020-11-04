---
chapter: 20
appendix: A
title: Getting and Preparing OSM Data
---

Osm2pgsql imports OSM data into a database. But where does this data come from?
This appendix shows how to get the data and, possibly, prepare it for use with
osm2pgsql.

### Data Formats

There are several common formats for OSM data and osm2pgsql supports all
of them ([XML](https://wiki.openstreetmap.org/wiki/OSM_XML){:.extlink},
[PBF](https://wiki.openstreetmap.org/wiki/PBF_Format){:.extlink}, and
[O5M](https://wiki.openstreetmap.org/wiki/O5m){:.extlink}). If you have the
option, you should prefer the PBF format, because the files are smaller than
those in other formats and faster to read.

*OSM data files* usually have a suffix `.osm`, `.osm.gz`, `.osm.bz2`, or
`.osm.pbf`, sometimes just `.pbf`. They are used in osm2pgsql "create" mode.

*OSM change files* usually have the suffix `.osc.gz`. They are used in
osm2pgsql "append" mode.

### Getting the Data

#### The Planet File

The OpenStreetMap project publishes the so-called "planet file", which contains
a dump of the current full OSM database. This dump is available in XML and PBF
format.

Downloads are available on [planet.osm.org](https://planet.osm.org/){:.extlink}
and several
[mirrors](https://wiki.openstreetmap.org/wiki/Planet.osm#Planet.osm_mirrors){:.extlink}.

If you are new to osm2pgsql we recommend you start experimenting with a small
extract, not the planet file! The planet file is huge (tens of GBytes) and it
will take many hours to import.
{: .note}

#### Geographical Extracts

Importing data into the database takes time and uses a lot of disk space.
If you only need a portion of the OSM data it often makes sense to only import
an extract of the data.

Geographical extracts for countries, states, cities, etc. are available from
[several
sources](https://wiki.openstreetmap.org/wiki/Planet.osm#Country_and_area_extracts){:.extlink}.

The [extracts from Geofabrik](https://download.geofabrik.de/){:.extlink} are
very popular. They are updated daily and also offer daily change files suitable
for updating an osm2pgsql database.

If you can't find a suitable extract, see below for creating your own.

### Updating an Existing Database

There are two steps when updating an existing database.

1. Download a change file ("diff") with recent changes of the OSM data
2. Load changes into the database

The second step is done with osm2pgsql in "append" mode, for the first step
there are several options. We recommend the
[`pyosmium_get_changes.py`](https://docs.osmcode.org/pyosmium/latest/tools_get_changes.html){:.extlink}
tool from the [PyOsmium](https://osmcode.org/pyosmium/){:.extlink} project.
With it, downloading all changes since you ran the program the last time is
just a single command.

OSM change files, sometimes called replication diffs, are available from
[planet.osm.org](https://planet.osm.org/replication/){:.extlink}.
Depending on how often you want to update your database, you can get
minutely, hourly, or daily change files.

Some services offering OSM data extracts for download also offer change files
suitable for updating those extracts.

When you have changes for many months or years it might make more sense to drop
your database completely and re-import from a more current OSM data file
instead of updating the database from change files.

If you have imported an extract into an osm2pgsql database but there are no
change files for the area of the extract, you can use still use the extracts
from planet.osm.org to update your database. But, because those extracts
contain data for the whole planet, your database will keep accumulating more
and more data outside the area of your extract that you don't really need.

### Preparing OSM Data for Use by Osm2pgsql

Before some OSM data file can be given to osm2pgsql it is sometimes necessary
to prepare it in some way. This chapter explains some options.

For most of these steps, the recommended application is the
[osmium](https://osmcode.org/osmium-tool/){:.extlink} command line tool, which
offers a wide range of functionality of slicing and dicing OSM data.

One handy command is [`osmium
fileinfo`](https://docs.osmcode.org/osmium/latest/osmium-fileinfo.html){:.extlink}
which can tell you a lot about an OSM file, including how many objects it
contains, whether it is sorted, etc.

#### Creating Geographical Extracts

You can create your own extracts from the planet file or from existing
extracts with the [`osmium
extract`](https://docs.osmcode.org/osmium/latest/osmium-extract.html){:.extlink}
command. It can create extracts of OSM data from a bounding box or from a
boundary.

#### Merging OSM Data Files

If you are working with extracts you sometimes have several extracts, lets
say for different countries, that you want to load into the same database.
The correct approach in this case is to merge those extracts first and then
import the resulting file with osm2pgsql.

You can use the [`osmium
merge`](https://docs.osmcode.org/osmium/latest/osmium-merge.html){:.extlink}
command for this.

#### Merging OSM Change Files

To speed up processing when you have many OSM change files, you can merge
several change files into larger files and then process the larger files with
osm2pgsql. The [`osmium
merge-changes`](https://docs.osmcode.org/osmium/latest/osmium-merge-changes.html){:.extlink}
command will do this for you. Make sure to use the option `-s, --simplify`.

Usually you should not merge change files for more than a day or so when doing
this, otherwise the amount of changes osm2pgsql has to process in one go
becomes too large.

#### OSM Data with Negative Ids

OSM data usually uses positive numbers for the ids of nodes, ways, and
relations. Negative numbers are sometimes used for inofficial OSM data, for
instance when non-OSM data is mixed with OSM data to make sure the are no id
clashes.

Osm2pgsql can only handle positive ids. It uses negative ids internally (for
multipolygon geometries in the database).

If you have negative ids in your input file, you can renumber it first. You can
use the [`osmium
renumber`](https://docs.osmcode.org/osmium/latest/osmium-renumber.html){:.extlink} command
for this.

Older versions of osm2pgsql will sometimes work or appear to work with
negative ids, but it is not recommended to rely on this, because the
processed data might be corrupted. Versions from 1.3.0 warn when you are
using negative ids. From version 1.4.0 on, only positive ids are allowed.
{:.note}

#### Handling Unsorted OSM Data

OSM data files are almost always sorted, first nodes in order of their ids,
then ways in order of their ids, then relations in order of their ids. The
planet files, change files, and usual extracts all follow this convention.

Osm2pgsql can only read OSM files ordered in this way. This allows some
optimizations in the code which speed up the normal processing.

If you have an unsorted input file, you should sort it first. You can use the
[`osmium sort`](https://docs.osmcode.org/osmium/latest/osmium-sort.html){:.extlink}
command for this.

Older versions of osm2pgsql will sometimes work or appear to work with
unsorted data, but it is not recommended to rely on this, because the
processed data might be corrupted. Versions from 1.3.0 warn when you are
using unsorted data. From version 1.4.0 on, only sorted OSM files are allowed.
{:.note}

#### Working with OSM History Data

OpenStreetMap offers [complete dumps of *all* OSM
data](https://wiki.openstreetmap.org/wiki/Planet.osm/full){:.extlink} which
include not only the current version of all objects like the normal planet
dump, but also all earlier version of OSM objects including deleted ones.

Like most other OSM software, osm2pgsql can *not* handle this data.

For some use cases there is a workaround: Create extracts from the full history
dump for specific points in time and feed those to osm2pgsql. You can use the
[`osmium
time-filter`](https://docs.osmcode.org/osmium/latest/osmium-time-filter.html){:.extlink}
command to create such extracts.

