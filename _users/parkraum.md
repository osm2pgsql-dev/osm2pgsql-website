---
title: Parkraumanalyse
order: 5
links:
    - href: https://parkraum.osm-verkehrswende.org/
      title: Project page "Parkraumanalyse"
    - href: https://tilda-geo.de/regionen/parkraum
      title: Map page "Parkraumanalyse"
    - href: https://github.com/osmberlin/osm-parking-processing
      title: Github project page
tags:
    - map
    - analysis
    - open source
---

In the project "Parkraumanalyse" (parking space analysis) OpenStreetMap data
about parking spaces along roads and on parking lots is analysed in incredible
detail. This helps with understanding how much parking is available in specific
areas and how this will be affected by road changes, for instance when new
cycle lanes are introduced.

The analysis uses osm2pgsql to extract exactly the data needed from OSM and
import it into a database where SQL scripts will do sophisticated processing
to prepare the data for visualization.

