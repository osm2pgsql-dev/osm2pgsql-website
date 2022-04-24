---
layout: doc
title: Manual Pages
---

<h2>osm2pgsql</h2>

{% assign mpages = site.manpages | where_exp: "item", "item.version != 'Development version'" | sort: "version" | reverse -%}
{% assign dev = site.manpages | where: "version", "Development version" | first -%}
<ul>
<li><a href="{% link doc/man/latest.md %}">Latest version</a></li>
{% for manpage in mpages -%}
<li><a href="{{ manpage.url }}">Version {{ manpage.version }}</a></li>
{% endfor -%}
<li><a href="{{ dev.url }}">{{ dev.version }}</a></li>
</ul>

<h2>osm2pgsql-replication</h2>

<p>This man page is only available for newer versions of osm2pgsql.</p>

{% comment %}
Create man pages with: groff -mandoc -Thtml docs/osm2pgsql-replication.1
{% endcomment %}

<ul>
<li><a href="{% link doc/man/osm2pgsql-replication-1.6.0.md %}">Version 1.6.0</a></li>
</ul>

