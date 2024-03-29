---
title: Releases
---

# Releases

<div class="releases-container">
{% for release in site.data.releases -%}
<div markdown="1">

## Release {{ release.version }}

Released on {{ release.date }}

* [Release notes](https://github.com/osm2pgsql-dev/osm2pgsql/releases/tag/{{ release.version }})
{% if release.manpage -%}
* [Man page](/doc/man/version-{{ release.version | slugify }}.html)
{%- endif %}

### Downloads

* [Source code (tar.gz)](/download/osm2pgsql-{{ release.version }}.tar.gz)
* [Source code (zip)](https://codeload.github.com/osm2pgsql-dev/osm2pgsql/zip/{{ release.version }})
* [Windows binary (64bit)](/download/windows/osm2pgsql-{{ release.version }}-x64.zip)

</div>
{% endfor -%}
</div>

<section markdown="1">

## Older Releases

For older releases see [the Github releases
page](https://github.com/osm2pgsql-dev/osm2pgsql/releases){:.extlink}.

</section>

