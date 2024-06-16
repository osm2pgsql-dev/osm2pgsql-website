---
title: OpenCampingMap
order: 4
links:
    - href: https://opencampingmap.org/
      title: OpenCampingMap
    - href: https://github.com/giggls/osmpoidb
      title: osmpoidb
    - href: https://wiki.openstreetmap.org/wiki/Tag:tourism%3Dcamp_site
      title: The tag tourism=camp_site
tags:
    - map
    - analysis
    - open source
---

The specialized OpenCampingMap shows campsites around the world. It is based on
the osm2pgsql flex output. OSM data about camp sites and other POI data is
updated hourly into PostgreSQL/PostGIS database.

OpenCampingMap aggregates data from several OSM objects. It uses OSM objects
with the tag `tourism=camp_site` as well as other objects in the vicinity to
analyze which amenities such as toilets, showers, sports facilities, etc. are
available on this camp ground. For this the osm2pgsql Lua config file and
additional SQL commands work together showing the power of having a flexible
relation database for complex OSM data analysis.
