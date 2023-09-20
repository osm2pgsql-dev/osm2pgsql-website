---
title: Generalization
---

# Generalization

[*Cartographic
generalization*](https://en.wikipedia.org/wiki/Cartographic_generalization){:.extlink}
is the process turning detailed geographic data into more general data for
smaller zoom levels or smaller scale maps. It is essential for generating
good-looking, easy to interpret, and fast rendering small scale maps.

Currently osm2pgsql has almost no built-in support for generalization, usually
it is done using lots of SQL magic after the initial import of the data with
osm2pgsql. From September 2022 to February 2023 we ran a
[project](https://prototypefund.de/project/generalisierung-von-openstreetmap-daten-mit-osm2pgsql/){:.extlink}
funded by the [Prototype Fund](https://prototypefund.de/){:.extlink} and the
[German Federal Ministry of Education and
Research](https://www.bmbf.de/){:.extlink} to add more support for
generalization to osm2pgsql. This included adding some generalization support
directly to osm2pgsql but also using the capabilities of the PostgreSQL
database and especially the PostGIS extension in a more easy to use fashion.

Here are the posts from Jochen's blog describing the progress of the project:

* [Generalization of OSM data](https://blog.jochentopf.com/2022-11-03-generalization-of-osm-data.html){:.extlink}
* [Selection of generalization problems](https://blog.jochentopf.com/2022-11-07-selection-of-generalization-problems.html){:.extlink}
* [Finding representative points for polygons](https://blog.jochentopf.com/2022-11-10-finding-representative-points-for-polygons.html){:.extlink}
* [Processing architecture for generalization in osm2pgsql](https://blog.jochentopf.com/2022-11-15-processing-architecture-for-generalization-in-osm2pgsql.html){:.extlink}
* [Generalizing polygons](https://blog.jochentopf.com/2022-11-21-generalizing-polygons.html){:.extlink}
* [PostgreSQL raster experiments](https://blog.jochentopf.com/2022-12-14-postgresql-raster-experiments.html){:.extlink}
* [Selecting settlements to display](https://blog.jochentopf.com/2022-12-19-selecting-settlements-to-display.html){:.extlink}
* [Deriving built-up areas](https://blog.jochentopf.com/2022-12-23-deriving-built-up-areas.html){:.extlink}
* [Generalizing river networks](https://blog.jochentopf.com/2023-01-30-generalizing-river-networks.html){:.extlink}
* [Tile expiry and generalization](https://blog.jochentopf.com/2023-02-25-tile-expiry-and-generalization.html){:.extlink}
* [Generalization project wrapup](https://blog.jochentopf.com/2023-03-13-generalization-project-wrapup.html){:.extlink}

And here are the most important related pull requests (already merged):
* [PR 1822 (Pole of Inaccessibility)](https://github.com/osm2pgsql-dev/osm2pgsql/pull/1822){:.extlink}
* [PR 1942 (Add support for data generalization)](https://github.com/osm2pgsql-dev/osm2pgsql/pull/1942){:.extlink}

In addition a lot of code has been added in many small PRs to add and extend
some (basic) functionality needed for this project.

The code is now merged into osm2pgsql master branch but still marked as
experimental. See the [preliminary
documentation](/doc/manual.html#generalization) for all the details.

Jochen gave a talk (in German) about this project at FOSSGIS 2023:
[slides](https://media.jochentopf.com/media/2023-03-16-talk-fossgis2023-generalisierung-von-osm-daten-de-slides.pdf){:.extlink},
[video download](https://media.jochentopf.com/media/2023-03-16-talk-fossgis2023-generalisierung-von-osm-daten-de-video.mp4){:.extlink}

<div id="sponsorlist">

<div>
<a href="https://prototypefund.de/"><img src="PrototypeFund-P-Logo.svg" height="140"/></a>
</div>

<div style="text-align: center;">
<a href="https://www.bmbf.de/"><img src="bmbf-logo.png" height="110"/></a>
<p>September 2022 bis Februar 2023<br/>FKZ 01IS22S29</p>
</div>

</div>

