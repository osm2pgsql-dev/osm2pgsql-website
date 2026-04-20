---
layout: post
title: OSM-Carto switched to flex output
---

Nearly six years ago we introduced the "flex" output in osm2pgsql version 1.3.0
and then improved it over the years adding more and more functionality. About a
month ago
[OpenStreetMap-Carto](https://github.com/openstreetmap-carto/openstreetmap-carto),
the iconic OSM map style switched to using the "flex" output in [version
6.0.0](https://www.openstreetmap.org/user/imagico/diary/408344). And now the
[OSM Foundation has finished their gradual rollout of the new
version](https://en.osm.town/@osm_tech/116397182590585788). So the most
important user of osm2pgsql doesn't need the old "pgsql" output any more.

That switch has been eagerly awaited by the osm2pgsql maintainers, because it
means we can start planning to retire the old "pgsql" output in earnest. This
will allow us to remove a lot of code and simplify other parts of osm2pgsql
making it easier to maintain and improve in the long term. We have already
marked the "pgsql" output as deprecated with [version
2.0.0](https://osm2pgsql.org/news/2024/09/19/release-2.0.0.html) released in
2024, so this shouldn't come as a surprise. The old "pgsql" output will not go
away immediately, but it will also not be available forever. If you are still
using it, start migrating your styles.

