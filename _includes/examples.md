
These examples show some use cases of osm2pgsql and highlight some features.

<div class="example-container">

<a class="example" href="{% link examples/raster-tiles/index.md %}">
    <img alt="" src="{% link examples/raster-tiles/tiles.png %}"/>
    <h2>Raster Tiles</h2>
    <p>This is the "classical" job of osm2pgsql: Import OSM data into a
    database to create raster tiles from.</p>
</a>

<a class="example" href="{% link examples/vector-tiles/index.md %}">
    <img alt="" src="{% link examples/vector-tiles/streets-of-brussels-small.png %}"/>
    <h2>Vector Tiles</h2>
    <p>Osm2pgsql imports OSM data using a very flexible configuration making
    it easy to generate any kind of vector tiles.</p>
</a>

<a class="example" href="{% link examples/nominatim/index.md %}">
    <h2>Nominatim</h2>
    <p>The Nominatim Geocoder uses osm2pgsql for the import of OSM data. It
    adds its own postprocessing to create the special data structures needed
    for geocoding.</p>
</a>

<a class="example" href="{% link examples/buildings/index.md %}">
    <img alt="" src="{% link examples/buildings/brasilia2-small.png %}"/>
    <h2>Building Map</h2>
    <p>Need only a few feature types? Import only what you need for a quick
    map.</p>
</a>

<a class="example" href="{% link examples/antarctica/index.md %}">
    <img alt="" src="{% link examples/antarctica/antarctica1-small.png %}"/>
    <h2>Antarctica Map</h2>
    <p>Osm2pgsql can use many different projections to fit the area covered
    and your use case.</p>
</a>

<a class="example" href="{% link examples/road-length/index.md %}">
    <h2>Geospatial Analysis</h2>
    <p>An osm2pgsql database is well-suited for geospatial analysis using
    the power of the PostGIS database extension.</p>
</a>

<a class="example" href="{% link examples/export/index.md %}">
    <img alt="" src="{% link examples/export/export.svg %}"/>
    <h2>Exporting OSM Data</h2>
    <p>Osm2pgsql and a database can be used as a step in exporting OSM data
    into many different GIS formats.</p>
</a>

</div>
