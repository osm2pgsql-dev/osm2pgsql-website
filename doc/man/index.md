---
layout: doc
title: Manual Pages
---

<h2>osm2pgsql</h2>

{% assign dev = site.manpages | where: "version", "Development version" | first -%}
<ul>
{% assign sortedreleases = site.releases | sort: 'date' | reverse %}
{% for release in sortedreleases -%}
{% if release.manpages -%}
<li><a href="/doc/man/version-{{ release.version | slugify }}.html">Version {{ release.version }}</a></li>
{%- endif %}
{% endfor -%}
</ul>

<h2>osm2pgsql-replication</h2>

<p>This man page is only available for newer versions of osm2pgsql.</p>

{% comment %}
Create man pages with: groff -mandoc -Thtml man/osm2pgsql-replication.1
{% endcomment %}

<ul>
<li><a href="{% link doc/man/osm2pgsql-replication-1.11.0.md %}">Version 1.11.0</a></li>
<li><a href="{% link doc/man/osm2pgsql-replication-1.10.0.md %}">Version 1.10.0</a></li>
<li><a href="{% link doc/man/osm2pgsql-replication-1.9.2.md %}">Version 1.9.2</a></li>
<li><a href="{% link doc/man/osm2pgsql-replication-1.9.1.md %}">Version 1.9.1</a></li>
<li><a href="{% link doc/man/osm2pgsql-replication-1.9.0.md %}">Version 1.9.0</a></li>
<li><a href="{% link doc/man/osm2pgsql-replication-1.7.1.md %}">Version 1.7.1</a></li>
<li><a href="{% link doc/man/osm2pgsql-replication-1.6.0.md %}">Version 1.6.0</a></li>
</ul>

