---
chapter: 7
title: Middle
---

This chapter is incomplete.
{:.wip}

The middle keeps track of all OSM objects read by osm2pgsql and the
relationships between those objects. It knows, for instance, which ways are
used by which nodes, or which members a relation has. It also keeps track of
all node locations. It information is necessary to build way geometries from
way nodes and relation geometries from members and it is necessary when
updating data, because OSM change files only contain changes objects themselves
and not all the related objects needed for creating an objects geometry.

{% include_relative options/middle.md %}

