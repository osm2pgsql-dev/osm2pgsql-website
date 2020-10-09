---
chapter: 8
title: Expire
---

This chapter is incomplete.
{:.wip}

When osm2pgsql is processing OSM changes, it can create a list of tiles that
will be affected by those changes. This list can later be used to delete any
changed tiles you might have cached. Osm2pgsql only creates this list. How
to actually expire the tiles it outside the scope of osm2pgsql. Expire only
makes sense in *append* mode.

{% include_relative options/expire.md %}
