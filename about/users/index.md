---
title: Who uses osm2pgsql?
---

# Who uses osm2pgsql?

Here is a list of some projects and services using osm2pgsql. This is, of
course, far from complete. Do you have an interesting project and use
osm2pgsql? Give us a shout!

<div class="user-container">
{% assign sortedusers = site.users | sort: 'order' -%}
{% for user in sortedusers -%}
    {%- assign name = user.path | split: "/" | last | split: "." | first -%}
<div class="user">
    <div class="user-bg" style="background-image: image-set(url({{ name }}.png) 1x, url({{ name }}.png) 2x);">
        <div class="user-tags">
{% for tag in user.tags -%}
            <span>{{ tag }}</span>
{% endfor -%}
        </div>
    </div>
    <h2>{{ user.title }}</h2>
    <div class="user-text">
        {{ user.content | markdownify }}
    </div>
    <ul>
{% for link in user.links -%}
        <li><a href="{{ link.href }}">{{ link.title }}</a></li>
{% endfor -%}
    </ul>
</div>
{% endfor -%}
</div>
