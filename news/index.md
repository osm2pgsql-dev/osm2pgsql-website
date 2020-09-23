---
layout: default
title: News
---

# News

<div style="text-align: right;"><a href="{% link news/feed.xml %}"><img src="{% link img/feed.svg %}" width="20" height="20" alt="Atom Feed" title="Atom Feed"/></a></div>

<div class="news-list">
{% for post in site.posts %}
<article>
    <div class="news-date-small">{{ post.date | date_to_string }}</div>
    <h2><a href="{{ post.url }}">{{ post.title }}</a></h2>
    <div class="news-text">
{{ post.excerpt }}
    <a href="{{ post.url }}">More...</a>
    </div>
</article>
{% endfor %}
</div>
