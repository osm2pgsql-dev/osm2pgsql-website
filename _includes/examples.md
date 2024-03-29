
These examples show some use cases of osm2pgsql and highlight some features.

<div class="example-container">

<a class="example" href="{% link examples/raster-tiles/index.md %}">
    <img alt="" src="{% link examples/raster-tiles/tiles.png %}"/>
    <h3>Raster Tiles</h3>
    <p>This is the "classical" job of osm2pgsql: Import OSM data into a
    database to create raster tiles from.</p>
</a>

<a class="example" href="{% link examples/vector-tiles/index.md %}">
    <img alt="" src="{% link examples/vector-tiles/streets-of-brussels-small.png %}"/>
    <h3>Vector Tiles</h3>
    <p>Osm2pgsql imports OSM data using a very flexible configuration making
    it easy to generate any kind of vector tiles.</p>
</a>

<a class="example" href="{% link examples/nominatim/index.md %}">
    <h3>Nominatim</h3>
    <p>The Nominatim Geocoder uses osm2pgsql for the import of OSM data. It
    adds its own postprocessing to create the special data structures needed
    for geocoding.</p>
</a>

<a class="example" href="{% link examples/buildings/index.md %}">
    <img alt="" src="{% link examples/buildings/brasilia2-small.png %}"/>
    <h3>Building Map</h3>
    <p>Need only a few feature types? Import only what you need for a quick
    map.</p>
</a>

<a class="example" href="{% link examples/antarctica/index.md %}">
    <img alt="" src="{% link examples/antarctica/antarctica1-small.png %}"/>
    <h3>Antarctica Map</h3>
    <p>Osm2pgsql can use many different projections to fit the area covered
    and your use case.</p>
</a>

<a class="example" href="{% link examples/road-length/index.md %}">
    <h3>Geospatial Analysis</h3>
    <p>An osm2pgsql database is well-suited for geospatial analysis using
    the power of the PostGIS database extension.</p>
</a>

<a class="example" href="{% link examples/poi-db/index.md %}">
    <img alt="" src="{% link examples/poi-db/pois-berlin-small.png %}"/>
    <h3>Creating a POI map</h3>
    <p>Use osm2pgsql to create a points-of-interest map.</p>
</a>

<a class="example" href="{% link examples/3dbuildings/index.md %}">
    <img alt="" src="{% link examples/3dbuildings/3dbuildings-small.png %}"/>
    <h3>3d Buildings</h3>
    <p>Use height information on OSM buildings to create a simple 3d map.</p>
</a>

<a class="example" href="{% link examples/export/index.md %}">
    <img alt="" src="{% link examples/export/export.svg %}"/>
    <h3>Exporting OSM Data</h3>
    <p>Osm2pgsql and a database can be used as a step in exporting OSM data
    into many different GIS formats.</p>
</a>

<a class="example" href="{% link examples/raw-data-publication/index.md %}">
    <img alt="" src="{% link examples/raw-data-publication/data-symbol.svg %}"/>
    <h3>Raw Data Publication</h3>
    <p>The raw OSM data can be published via a web API using pg_featureserv</p>
</a>

</div>
