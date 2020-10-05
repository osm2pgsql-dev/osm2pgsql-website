---
layout: doc
title: Manual Pages
---

{% assign mpages = site.manpages | where_exp: "item", "item.version != 'Development version'" | sort: "version" | reverse -%}
{% assign dev = site.manpages | where: "version", "Development version" | first -%}
<ul>
<li><a href="{% link doc/man/latest.md %}">Latest version</a></li>
{% for manpage in mpages -%}
<li><a href="{{ manpage.url }}">Version {{ manpage.version }}</a></li>
{% endfor -%}
<li><a href="{{ dev.url }}">{{ dev.version }}</a></li>
</ul>
