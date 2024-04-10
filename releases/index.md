---
title: Releases
---

# Releases

<div class="releases-container">
{% assign sortedreleases = site.releases | sort: 'date' | reverse %}
{% for release in sortedreleases -%}
<div>
    <b><a href="{{ release.version | slugify }}.html">Release {{ release.version }}</a></b> ({{ release.date | date: "%Y-%m-%d" }})
    <ul>
{% for hl in release.highlights -%}
        <li>{{ hl }}</li>
{% endfor -%}
    </ul>
</div>
{% endfor -%}
</div>

<section markdown="1">

## Older Releases

For older releases see [the Github releases
page](https://github.com/osm2pgsql-dev/osm2pgsql/releases){:.extlink}.

</section>

