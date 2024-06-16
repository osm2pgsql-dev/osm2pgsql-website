---
title: Nominatim
order: 2
links:
    - href: https://nominatim.org/
      title: Nominatim
    - href: https://www.openstreetmap.org/
      title: OpenStreetMap
    - href: https://nominatim.org/release-docs/latest/admin/Installation/
      title: Nominatim Installation
tags:
    - geocoding
    - analysis
    - open source
---

Nominatim uses OpenStreetMap data to find locations on Earth by name and/or
address. This is called geocoding. It can also do the reverse, find an address
for any location on the planet.

Nominatim powers the search on the official OSM site at openstreetmap.org. It
serves 30 million queries per day on a single server. And it is always kept up
to date using osm2pgsql. Nominatim uses database triggers in the
PostgreSQL/PostGIS database to analyse the data and build a hierarchy of places
from country level, down to state, city, and finally the individual address.

Nominatim is Open Source and you can set it up for yourself.
