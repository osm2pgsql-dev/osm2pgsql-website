---
title: Releases
---

# Releases

{% for release in site.data.releases -%}
<section markdown="1">

## Release {{ release.version }}

Released on {{ release.date }}

* [Release notes](https://github.com/openstreetmap/osm2pgsql/releases/tag/{{ release.version }})
{% if release.manpage -%}
* [Man page](/doc/man/version-{{ release.version | slugify }})
{%- endif %}

### Downloads

* [Source code (zip)](https://github.com/openstreetmap/osm2pgsql/archive/{{ release.version }}.zip)
* [Source code (tar.gz)](https://github.com/openstreetmap/osm2pgsql/archive/{{ release.version }}.tar.gz)
* [Windows binary (64bit)](https://lonvia.dev.openstreetmap.org/osm2pgsql-winbuild/releases/osm2pgsql-1.3.0-x64.zip)

</section>
{% endfor -%}

<section markdown="1">

## Older Releases

For older releases see [the Github releases
page](https://github.com/openstreetmap/osm2pgsql/releases){:.extlink}.

</section>

