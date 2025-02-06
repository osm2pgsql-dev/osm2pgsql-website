---
title: History
---

# osm2pgsql Project History

<p class="history-chart"><a href="https://github.com/osm2pgsql-dev/osm2pgsql/graphs/contributors"><img src="{% link about/history/contributors.png %}" alt="Contribution statistics" title="Contribution statistics"/></a></p>

<div class="contributors-list">
    <h2>Contributions</h2>
    <table>
        <tbody id="contributor-table"></tbody>
    </table>
</div>

<div class="history" markdown="1">

## 2006

The osm2pgsql project was started in 2006 by Jon Burgess
([@jburgess777](https://github.com/jburgess777)) and written in C.
This makes the project nearly as old as the OpenStreetMap project itself.

## 2007

In 2007 OSM moved to API 0.5 adding the *relation* data type. Shortly
thereafter osm2pgsql got support for multipolygon relations, allowing polygons
to have holes for the first time. Also in 2007 osm2pgsql added support for
multiple projections, beyond the WGS84 lat/lon projection and Web Mercator used
before.

## 2008

Support for reading OSM change files was added to osm2pgsql in 2008. From 2009
on the main OSM map was re-generated based on minutely changes. This was a
major achievement at a time when most maps on the Internet were updated only a
few times per year. The toolchain importing the data with osm2pgsql into a
PostgreSQL/PostGIS database and then rendering tiles with Mapnik proves up to
the task.

## 2009

Brian Quinion ([@twain47](https://github.com/twain47)) created
the geocoder [Nominatim](https://nominatim.org/){:.extlink} which to this day
powers the search on
[openstreetmap.org](https://www.openstreetmap.org/){:.extlink} and many other
map sites. Nominatim uses osm2pgsql as a basis, the special *gazetteer* output
was added for that.

## 2011

The number of nodes in OpenStreetMap is growing rapidly passing the one billion
mark. Osm2pgsql is changed to use 64 bit IDs to allow for the
expected growth beyond two billion nodes.

Kai Krueger ([@apmon](https://github.com/apmon/)) takes over as maintainer
from Jon Burgess.

## 2012

The flat file persistent node cache for slim mode is introduced, drastically
reducing disk usage and improving import and update performance a lot.

## 2013

The ability to have complex tag transformation on import through Lua scripting
is introduced.

## 2014

Matt Amos ([@zerebubuth](https://github.com/zerebubuth))
together with Kevin Kreiser ([@kevinkreiser](https://github.com/kevinkreiser/))
start the move from C to C++, a process which will take many years to complete.

Sarah Hoffmann ([@lonvia](https://github.com/lonvia)) and
Paul Norman ([@pnorman](https://github.com/pnorman)) take over as maintainers.

## 2015

osm2pgsql starts using the [libosmium
library](https://osmcode.org/libosmium/){:extlink} for parsing OSM data.
First parsing of XML and PBF files was switched, later on also the o5m parsing
code.

## 2017

Geometry generation is also switched to libosmium and GEOS is not used any
more. This makes especially the multipolygon generation more robust and
improves performance.

## 2018

Support for LuaJIT is added, making imports with complex tag transformations
much faster.

## 2019

With the 1.0 release, osm2pgsql drops processing of so called old-style
multipolygons. This allows for a major overhaul of the processing pipeline
and much improved import speed.

## 2020

The new *flex* output is introduced by Jochen Topf
([@joto](https://github.com/joto)). It allows a much more flexible
configuration of the output tables. The flex output is improved step by step
over the next years.

Also in 2020 osm2pgsql finally gets its own [website](https://osm2pgsql.org/).

## 2021

The OpenStreetMap project in general and osm2pgsql more specifically is used
more and more. The osm2pgsql repository passes 1000 stars on Github.

## 2022

Osm2pgsql has always been a tool to import OSM into a database. Many projects
have built upon that and done further processing of the data once it is in
the database, mostly using SQL scripts. Often this is done to generalize the
rather detailed OSM data for use in smaller zoom levels. In 2022 support for
generalization is added to osm2pgsql with the (experimental) `osm2pgsql-gen`
command. This work is funded by the [Prototype Fund](https://prototypefund.de/).

## 2023

A new database format for the *middle* is introduced replacing the somewhat
homegrown format with simpler to use JSONB data. This makes it possible for the
first time to store *all* OSM data including all tags, and all attributes and
member information for all objects in the database.

## 2024

Nominatim switches to the *flex* output, which makes the *gazetteer* output
obsolete. It is removed along with a lot of other obsolete functionality and
[version 2.0 is released]({% link _posts/2024-09-19-release-2.0.0.md %}).

</div>

<script>
const url = 'https://api.github.com/repos/osm2pgsql-dev/osm2pgsql/contributors';
const el = document.getElementById('contributor-table');
fetch(url)
  .then( (response) => {
    if (!response.ok) {
      throw new Error('HTTP error! Status: ${response.status}');
    }

    return response.json();
  })
  .then( (data) => {
    console.log(data);
    for (contributor of data) {
      el.innerHTML += '<tr><td><a href="' + contributor.html_url +
                      '"><img src="' + contributor.avatar_url +
                      '"/></a></td><td><a href="' + contributor.html_url + '">' +
                      contributor.login + '</a></td><td>' +
                      contributor.contributions + '</td></tr>';
    }
  });
</script>
