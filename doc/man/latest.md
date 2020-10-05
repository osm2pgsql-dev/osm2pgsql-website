---
layout: manpage
title: Latest version
---
{% assign latest = site.manpages | where_exp: "item", "item.version != 'Development version'" | sort: "version" | last %}

{{ latest.content }}
