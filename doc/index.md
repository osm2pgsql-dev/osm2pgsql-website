---
title: Documentation
---

# Osm2pgsql Documentation

<div class="container">

<a class="box box2" href="{% link doc/install.md %}">
    <h2><img src="{% link img/download.svg %}" alt=""/> Installation</h2>

    <p>Instructions for downloading and installing osm2pgsql on different architectures.</p>
</a>

<a class="box box2" href="{% link doc/manual.html %}">
    <h2><img src="{% link img/book.svg %}" alt=""/> Manual</h2>

    <p>The manual contains all the details about running osm2pgsql.</p>
</a>

<a class="box box2" href="{% link doc/man/index.md %}">
    <h2><img src="{% link img/document.svg %}" alt=""/> Man Page</h2>

    <p>The man page has a short overview about running the osm2pgsql command.</p>
</a>

<a class="box box2" href="{% link doc/faq.md %}">
    <h2><img src="{% link img/faq.svg %}" alt=""/> FAQ</h2>

    <p>The FAQ is a list of frequently asked questions and answers.</p>
</a>

</div>

The [osm2pgsql page](https://wiki.openstreetmap.org/wiki/Osm2pgsql){:.extlink}
on the OSM wiki also contains some more information, some of it outdated.

See a [list of releases]({% link releases/index.md %}).

<section markdown="1">

## Related Documentation

<div class="container">

<a class="box box3" href="https://switch2osm.org/serving-tiles/">
    <img src="{% link img/switch2osm.png %}" width="98" height="20" alt="Switch2OSM"/>

    <p>If you want to set up a whole rendering toolchain to create maps from
    OSM data, you need more than just osm2pgsql. Have a look at switch2osm to
    get started.</p>
</a>

<a class="box box3" href="https://www.postgresql.org/">
    <img src="{% link img/postgresql.png %}" width="30" height="31" alt="PostgreSQL"/>

    <p>You'll need to understand how PostgreSQL works to make the most out of
    osm2pgsql. Understanding at least a bit of the SQL query language and
    something about PostgreSQL configuration is important.</p>
</a>

<a class="box box3" href="https://postgis.net/">
    <img src="{% link img/postgis.png %}" width="54" height="32" alt="PostGIS"/>

    <p>The PostGIS plugin extends the PostgreSQL database with geometry data
    types such as `POINT` or `POLYGON`, the geometry operations that manipulate
    those data types, and special geometry indexes.</p>
</a>

</div>
</section>

