---
title: Features
---

# osm2pgsql Features

<div class="features">

<h3>Portability</h3>

<div class="features-info" markdown="1">
Osm2pgsql is a command line program written in modern, portable C++. It works
on Linux, Windows, macOS, and several other operating systems. It is available
on all major Linux distributions, Homebrew for macOS users, and we provide
bindary downloads for Windows. Docker images are provided from a third party.
[<img class="features-link" src="/img/infolink.svg" alt="More information" title="More information"/>](/doc/install.html)
</div>

<div class="features-list" markdown="1">
</div>

<h3>Scalability</h3>

<div class="features-info" markdown="1">
Osm2pgsql scales from a small geographical area to the whole world. You can
import the data for a city in seconds. Or you can have a database with all
OpenStreetMap data for the entire planet on a single machine in a few hours.
</div>

<div class="features-list" markdown="1">
</div>

<h3>Backwards Compatibility</h3>

<div class="features-info" markdown="1">
Keeping osm2pgsql stable is important, because it is used in production in many
places. That's why osm2pgsql is still able to run a ten year old configuration.
That being said, osm2pgsql is also rapidly developing new features and we
encourage you to take advantage of them.

Some features have been removed in the recently released 2.0 version. The
old pgsql backend is now deprecated and will be removed in version 3.
</div>

<div class="features-list" markdown="1">
</div>

<h3>Stay up-to-date with OSM</h3>

<div class="features-info" markdown="1">
An osm2pgsql database can be updated from OSM change files. If you want to,
you can keep your database current with only a few minutes delay from the
main OSM database.

Osm2pgsql comes with its own little helper program called
`osm2pgsql-replication` which makes updating your database a snap.
[<img class="features-link" src="/img/infolink.svg" alt="More information" title="More information"/>](/doc/manual.html#updating-an-existing-database)
</div>

<div class="features-list" markdown="1">
</div>

<h3>Table layout</h3>

<div class="features-info" markdown="1">
Define any number of tables in the database with any number of columns of any
type as you need them. Use builtin data conversion or define your own
conversion functions to get the data in the format best suited for your
applications.

Use PostgreSQL JSON and hstore data types to store the complete set of tags of
an OSM object in a single database column for maximum flexiblity or use
specific columns for specific attributes.
[<img class="features-link" src="/img/infolink.svg" alt="More information" title="More information"/>](/doc/manual.html#defining-columns)
</div>

<div class="features-list" markdown="1">
* text
* int, int2, int8
* real
* bool
* json(b)
* hstore
* (any other PostgreSQL datatype)
</div>

<h3>Configuration using a programming language</h3>

<div class="features-info" markdown="1">
Osm2pgsql is endlessly configurable, because it leverages the power of the
[Lua](https://www.lua.org/){:.extlink} programming language for its
configuration. The database table schema, indexes, expire and so on is all
configured with Lua code as well as the data cleanup and transformations.

The Lua config has access to environment variables allowing even more flexible
configuration. And with the use of Lua libraries functionality can be extended
even further.
[<img class="features-link" src="/img/infolink.svg" alt="More information" title="More information"/>](/doc/manual.html#the-flex-output)
</div>

<div class="features-list" markdown="1">
</div>

<h3>Valid geometries</h3>

<div class="features-info" markdown="1">
Osm2pgsl creates point, line, polygon, multipolygon, and other types of
geometries from OSM data and makes sure they are always valid. This makes
map rendering and further processing in the database much less error-prone.
[<img class="features-link" src="/img/infolink.svg" alt="More information" title="More information"/>](/doc/manual.html#geometry-processing)
</div>

<div class="features-list" markdown="1">
</div>

<h3>Geometry transformations</h3>

<div class="features-info" markdown="1">
Often used geometry transformation can be done by osm2pgsql while the data
is being imported. Data is not unnecessarily copied into the database in
intermediate steps.
[<img class="features-link" src="/img/infolink.svg" alt="More information" title="More information"/>](/doc/manual.html#geometry-objects-in-lua)
</div>

<div class="features-list" markdown="1">
* Centroid, Labelling point
* Simplification
* Splitting of multi-geometries
* ...
</div>

<h3>Projections</h3>

<div class="features-info" markdown="1">
While importing the geometries osm2pgsql can transform the coordinates into any
projection you want. It has builtin support for lightning fast conversion of
the OSM lon/lat coordinates to Web Mercator, the most popular format for map
tiles. Or it leverages the Proj library to convert coordinates into basically
any projection.

It is possible to use different projections for each table/column if that's
needed.
[<img class="features-link" src="/img/infolink.svg" alt="More information" title="More information"/>](/doc/manual.html#projections)
</div>

<div class="features-list" markdown="1">
* WGS84 (4326)
* Web Mercator (3857)
* Any Projection supported by Proj library
</div>

<h3>OSM file formats</h3>

<div class="features-info" markdown="1">
All popular OpenStreetMap file formats are supported when reading the data.

Multiple files can be read at the same time and their contents will be
merged.
[<img class="features-link" src="/img/infolink.svg" alt="More information" title="More information"/>](/doc/manual.html#processing-the-osm-data)
</div>

<div class="features-list" markdown="1">
* XML
* PBF
* OPL
* O5M
</div>

<h3>Organize your database</h3>

<div class="features-info" markdown="1">
Use schemas, tablespaces, or custom types to organize the database in the way
you like it.
[<img class="features-link" src="/img/infolink.svg" alt="More information" title="More information"/>](/doc/manual.html#the-flex-output)
</div>

<div class="features-list" markdown="1">
* schemas
* tablespaces
* custom types
</div>

<h3>Index creation</h3>

<div class="features-info" markdown="1">
Osm2pgsql will always automatically create the indexes it needs for updating
the data (if you want to update the data). By default it will also create
a geometry index for the first (or only) geometry in all tables. But you
can change that and tell osm2pgsql exactly what indexes you'll need and
it will create them. Index creation is run in parallel to speed up the
import.
[<img class="features-link" src="/img/infolink.svg" alt="More information" title="More information"/>](/doc/manual.html#defining-indexes)
</div>

<div class="features-list" markdown="1">
* btree indexes
* geometry indexes
* unique indexes
</div>

<h3>Tile expiry</h3>

<div class="features-info" markdown="1">
Most online maps use a tile-based approach, where the map is split into
rectangular (raster or vector) tiles that can be created, delivered and updated
independently. Osm2pgsql can create list of tiles that need updating based on
the changed OSM data.
[<img class="features-link" src="/img/infolink.svg" alt="More information" title="More information"/>](/doc/manual.html#expire)
</div>

<div class="features-list" markdown="1">
* expire files
* expire database tables
* use any zoom level or zoom level range
</div>

<h3>Sorting by geometry</h3>

<div class="features-info" markdown="1">
By default osm2pgsql will order the tables by geometry on import. This can
speed up further processing considerably, because data that's geographically
near to other data will probably be used together.

If not needed, this function can be disabled for a faster import.
[<img class="features-link" src="/img/infolink.svg" alt="More information" title="More information"/>](/doc/manual.html#clustering-by-geometry)
</div>

<div class="features-list" markdown="1">
</div>

<h3>Raw OSM data in database</h3>

<div class="features-info" markdown="1">
Osm2pgsql can create and update tables that contain *all* OSM data including
all tags, all attributes (version, creation timestamp, changeset, use id, user
name) as well as the relationships between ways and their member nodes and
relations and their members.
[<img class="features-link" src="/img/infolink.svg" alt="More information" title="More information"/>](/doc/manual.html#middle)
</div>

<div class="features-list" markdown="1">
* nodes
* ways
* relations
</div>

<h3>Handling untagged objects</h3>

<div class="features-info" markdown="1">
For performance you usually are only interested in *tagged* OSM objects.
But access to untagged objects is available for the special cases where
you need it.
[<img class="features-link" src="/img/infolink.svg" alt="More information" title="More information"/>](/doc/manual.html#processing-callbacks)
</div>

<div class="features-list" markdown="1">
* process_untagged_node()
* process_untagged_way()
* process_untagged_relation()
</div>

<h3>Two-stage processing for relations</h3>

<div class="features-info" markdown="1">
Osm2pgsql has advanced support for working with OSM relations. Using optional
two-stage processing tags and other information from relations can be attached
to their member objects. This is useful for *route* relations, for instance.
[<img class="features-link" src="/img/infolink.svg" alt="More information" title="More information"/>](/doc/manual.html#stages)
</div>

<div class="features-list" markdown="1">
</div>

<h3>Postprocessing (beta)</h3>

<div class="features-info" markdown="1">
Osm2pgsql can run several types of postprocessing steps after an initial
import of the OSM data or after updates of changed OSM data.

This is currently done with the separate `osm2pgsql-gen` command.
[<img class="features-link" src="/img/infolink.svg" alt="More information" title="More information"/>](/doc/man/osm2pgsql-gen-2-0-1.html)
</div>

<div class="features-list" markdown="1">
* Create any indexes
* Run any SQL
* Run any SQL per tile
</div>

<h3>Generalization (beta)</h3>

<div class="features-info" markdown="1">
Geographic data usually needs to be *generalized* for small zoom levels/small
map scales. This is difficult to do automatically and often quite slow.
Osm2pgsql implements several algorithms for generalization that can be used
at scale.
[<img class="features-link" src="/img/infolink.svg" alt="More information" title="More information"/>](/generalization/)
</div>

<div class="features-list" markdown="1">
* Line simplification
* Polygon simplification
* Tile-based generalization
* Discrete Isolation
</div>

<h3>Themepark (beta)</h3>

<div class="features-info" markdown="1">
*Themepark* is a framework for mixing and matching several configurations
into one, allowing you to re-use configurations others have written and
merge them with your own configurations to quickly assemble a setup that
works for you.

This can be used, for instance, to create different rendering styles from
the same database, or even to use one database for rendering and geocoding.
[<img class="features-link" src="/img/infolink.svg" alt="More information" title="More information"/>](/themepark/)
</div>

<div class="features-list" markdown="1">
</div>

</div>

