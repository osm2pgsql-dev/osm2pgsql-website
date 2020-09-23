---
layout: default
title: Home
---

# osm2pgsql

<section id="newsbox">
    <h2><a href="{% link news/index.md %}">News</a></h2>
    <a id="news-rss" href="{% link news/feed.xml %}"><img src="{% link img/feed.svg %}" width="16" height="16" alt="Atom Feed"/></a>
<table>
{% for post in site.posts %}
    <tr><td>{{ post.date | date_to_string }}:</td>
        <td><a href="{{ post.url }}">{{ post.title }}</a></td></tr>
{% endfor %}
</table>
</section>

<section markdown="1">
## About

Osm2pgsql imports [OpenStreetMap](https://www.openstreetmap.org/) data into a
PostgreSQL/PostGIS database. It is an essential part of many rendering
toolchains, the Nominatim geocoder and other applications processing OSM data.

</section>

<section markdown="1">
## Features

Flexible configuration

: Clean up and convert the OSM data in any way you like before importing into
  the database. Database table names, column structure, data types, can all
  be configured the way your application or style needs it.

Stay up-to-date with OSM

: An osm2pgsql database can be updated from OSM change files. If you want to,
  you can keep your database current with only a few minutes delay from the
  main OSM database.

Valid Geometries

: Osm2pgsl creates point, line, polygon, and multipolygon geometries from OSM
  data and makes sure they are always valid.

Portable

: Osm2pgsql is a command line program written in portable C++. It works on
  <img src="{% link img/linux.png %}" style="position: relative; top: 2px" width="12" height="12"/> Linux,
  <img src="{% link img/windows.png %}" style="position: relative; top: 2px" width="12" height="12"/> Windows, and
  <img src="{% link img/apple.png %}" style="position: relative; top: 1px" width="12" height="12"/> macOS.

Many OSM input formats

: Process OSM files of any type (in XML, PBF, or O5M format).

Any Projection

: Import geometries in Lon/Lat (WGS84), Web Mercator (most popular format for
  map tiles), or any other projection.

Support for hstore and JSON

: Use hstore and JSON(B) PostgreSQL data types to store the complete
  set of tags of an OSM object in a single database column.

Resource friendly

: You can run a database with *all* OpenStreetMap data for the whole planet
  on a single, reasonable-sized machine.


</section>

<section markdown="1">

## Sponsors

Developing and supporting osm2pgsql takes a huge amount of effort. We thank the
following companies and organizations for their support:

{% include sponsors.md %}

</section>

