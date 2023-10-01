---
layout: examples
title: Raw Data Publication
---

Exploring the raw OpenStreetMap data can be done in the database itself, but this limits the audience of users. To enable public access we need a web API that allows exploring, filtering and downloading of the data. This objective is achieved through the use of the established OGC API Features standard in conjunction with the [pg_featureserv](https://github.com/CrunchyData/pg_featureserv){:.extlink} program. The following example showcases this process.We want to analyse restaurants, so we create the lua file `restaurants.lua` with this content:

{% include download.html file="restaurants.lua" %}

```lua
{%- include_relative restaurants.lua -%}
```

Then we load the data in our database.

```sh
osm2pgsql -d osm -O flex -S restaurants.lua OSMDATA.osm.pbf
```

We can install `pg_featureserv` by downloading the binary from [here](https://access.crunchydata.com/documentation/pg_featureserv/latest/installation/installing/) {:.extlink}. Normally, `pg_featureserv` can run without any extra settings. But because we plan to show a simple map on the website later, we require further configuration. So, we create a configuration file called `pg_featureserv.toml` that has this content:

```toml
[Website]
# Add a source URL of maptiles to be shown as background for our features
BasemapUrl = "http://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png"
```

We must adjust the `DATABASE_URL` to match our setup. Then, we can initiate the API using this command:

```sh
DATABASE_URL=postgres://username:password@localhost/osm ./pg_featureserv --config=./pg_featureserv.toml
```

This service starts at the address [http://localhost:9000/](http://localhost:9000/){:.extlink}  and can be accessed directly from the browser. The metadata for our table, like the the extent or available attribute names, can be viewed on this page:

```
http://localhost:9000/collections/public.restaurants.html
```

The link below shows the data on the map. Please note that only a subset of all the features are displayed, but this can be changed in the user interface of the map. Clicking on a feature shows provides additional information of it:

```
http://localhost:9000/collections/public.restaurants/items.html
```

<a href="pg_featureserv.jpg">
  <img alt="Screenshot of pg_featureserv" class="fullwidth" src="pg_featureserv.jpg"  />
</a>

By changing the `.html` ending to `.json`, the data will be returned as GeoJSON. It includes all raw data like attributes or geometry. A GeoJSON can be processed with many clients such as OpenLayers, Leaflet, MapLibre, or QGIS. For performance reasons, in default mode `pg_featureserv` returns only 10 features per request. With the parameter `limit` we can increase this count :

```
http://localhost:9000/collections/public.restaurants/items.json?
limit=100
```

The response can be filtered by both spatial and non-spatial properties. Here we request restaurants restaurants with indian cuisine in an specific area.

```
http://localhost:9000/collections/public.restaurants/items.json?
limit=100&
bbox=8.4877,49.2583,9.1773,49.4579&
cuisine=indian
```

The response is a GeoJSON like this ([download](indian-restaurants.geojson)). Many programs or websites can display it as table like this:

<table border="1">
    <thead>
        <tr id="tableHeaders"></tr>
    </thead>
    <tbody id="tableBody"></tbody>
</table>

More advanced filtering can be done by using the `filter` keyword in CQL (Common Query Language). With the parameter `filter=name ILIKE '%restaurant%'` we can retrieve all features that have the word `restaurant` in their name. Note the value of `filter` must be encoded.

```
http://localhost:9000/collections/public.restaurants/items.json?
filter=name%20ILIKE%20%27%25restaurant%25%27%
```

<style>
        table {
            width: 80%;
            margin: 20px auto;
            border-collapse: collapse;
            border: 2px solid #333;
        }

        th, td {
            padding: 10px;
            border: 1px solid #333;
            text-align: left;
        }

        th {
            background-color: #333;
            color: #fff;
        }

        tr:nth-child(even) {
            background-color: #f2f2f2;
        }

        tr:hover {
            background-color: #ddd;
        }
</style>

<script>
const jsonUrl = 'indian-restaurants.geojson';

async function fetchData() {
    try {
        const response = await fetch(jsonUrl);
        const data = await response.json();
        const features = data.features;

        const tableHeadersRow = document.getElementById('tableHeaders');
        const tableBody = document.getElementById('tableBody');

        // Create column headers dynamically from properties
        const properties = Object.keys(features[0].properties);
        properties.push("Latitude", "Longitude");

        properties.forEach((property) => {
            const th = document.createElement('th');
            th.textContent = property;
            tableHeadersRow.appendChild(th);
        });

        features.forEach((feature) => {
            const row = tableBody.insertRow();
            properties.forEach((property) => {
                const cell = row.insertCell();
                if (property === "Latitude") {
                    cell.textContent = feature.geometry.coordinates[1];
                } else if (property === "Longitude") {
                    cell.textContent = feature.geometry.coordinates[0];
                } else {
                    cell.textContent = feature.properties[property];
                }
            });
        });
    } catch (error) {
        console.error('Error fetching JSON data:', error);
    }
}

fetchData();
</script>
