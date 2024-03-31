---
title: Releases
---

# Releases

<div class="releases-container">
{% assign sortedreleases = site.releases | sort: 'date' | reverse %}
{% for release in sortedreleases -%}
<div markdown="1">

## [Release {{ release.version }}]({{ release.version | slugify }}.html)

Released on {{ release.date | date: "%Y-%m-%d" }}

* [Release notes]({{ release.version | slugify }}.html)
{% if release.manpages.first == 'osm2pgsql' -%}
* [Man page](/doc/man/version-{{ release.version | slugify }}.html)
{%- endif %}
* [Github](https://github.com/osm2pgsql-dev/osm2pgsql/releases/tag/{{ release.version }})

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

