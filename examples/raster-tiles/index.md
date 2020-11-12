---
layout: examples
title: Raster Tiles
css:
    - /css/ol.css
javascript:
    - /js/ol.js
---

<img alt="" src="{% link examples/raster-tiles/tiles.png %}" style="float: right; position: relative; top: -60px;"/>

This is the "classical" job of osm2pgsql: Import data into a database, then use
Mapnik or another rendering engine to create raster tiles from the data.

The "standard" OSM map you see below and on
[openstreetmap.org](https://openstreetmap.org){:.extlink} uses osm2pgsql, the
[Mapnik](https://mapnik.org){:.extlink} renderer and the [OpenStreetMap
Carto](https://github.com/gravitystorm/openstreetmap-carto){:.extlink} style.
Some more information about it is [on the OSM
wiki](https://wiki.openstreetmap.org/wiki/Standard_tile_layer){:.extlink}. Many
other maps use a similar setup.

To learn more about how to set up a raster tile server see
[switch2osm](https://switch2osm.org/serving-tiles/).

<div id="map" class="map"></div>
<script>
var layer = new ol.layer.Tile({
    source: new ol.source.OSM()
});

var map = new ol.Map({
    layers: [layer],
    target: 'map',
    view: new ol.View({
        maxZoom: 18,
        center: ol.proj.fromLonLat([121, 14]),
        zoom: 10,
    }),
});
</script>
