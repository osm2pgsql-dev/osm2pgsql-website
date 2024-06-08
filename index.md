---
title: Home
---

# osm2pgsql

<section id="newsbox">
    <h2><a href="{% link news/index.md %}">News</a></h2>
    <a id="news-rss" href="{% link news/feed.xml %}"><img src="{% link img/feed.svg %}" width="16" height="16" alt="Atom Feed"/></a>
<table>
{%- for post in site.posts limit: 5 %}
    <tr><td class="news-date">{{ post.date | date_to_string }}:</td>
        <td><a href="{{ post.url }}">{{ post.title }}</a></td></tr>
{%- endfor %}
</table>
</section>

<section markdown="1">
## About

Osm2pgsql is an Open Source tool for importing
[OpenStreetMap](https://www.openstreetmap.org/){:.extlink} (OSM) data into a
PostgreSQL/PostGIS database. Essentially it is a very specialized ETL
(Extract-Transform-Load) tool for OpenStreetMap data. [PostgreSQL
database](https://www.postgresql.org/){:.extlink} is the most advanced Open
Source database, together with the [PostGIS](https://postgis.net/){:.extlink}
extension for handling geographical data it offers an extremely powerful
way of working with OpenStreetMap data.

Osm2pgsql is an essential part of many services that take OSM data and create
maps from it. It is also used in the Nominatim geocoder and numerous other
applications processing OSM data.

[More about osm2pgsql:]({% link about/index.md %})
* [Features]({% link about/features/index.md %})
* [Project history]({% link about/history/index.md %})
* [Who is using osm2pgsql?]({% link about/users/index.md %})
</section>

<section markdown="1">

## Examples

{%- include examples.md -%}

</section>

<section markdown="1">

## Sponsors

Developing and supporting osm2pgsql takes a huge amount of effort. We thank the
following companies and organizations for their support:

{% include sponsors.md %}

</section>
