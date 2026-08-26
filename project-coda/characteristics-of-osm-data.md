---
title: Characteristics of OSM data
layout: coda
---

There are plenty of options out there to store data in multipurpose database
systems including relational databases and many other types of database.
Osm2pgsql uses PostgreSQL to store OSM data.

But OpenStreetMap data has certain characteristics that can be used to store or
process it more efficiently than "general" data. Using these characteristics
wisely, we can make our own database implementation more efficient or use less
ressources than a general purpose database.

We have a well-known precendent in OSM for this, our file formats: Originally OSM used
the generic XML format for its data, and that is still available. But more
common is now the PBF format which was specifically invented for OSM data and
uses numerous tricks to store the data more efficiently. But that format is
not made for updates, files can only be written in one go. Every change needs
a complete rewrite. So we have to come up with something different.

For this we'll first look very closely at OSM data to identify places that
might give us opportunities for optimizing a database format.

Links:

* [OSM PBF](https://wiki.openstreetmap.org/wiki/PBF_Format)
* [OSM Elements](https://wiki.openstreetmap.org/wiki/Elements)

## IDs

OSM objects of any type (nodes, ways, and relations) have 64bit integer IDs. ID
spaces for nodes ways, and relations are separate, all IDs are given out from 1
in ascending order. The ID 0 is not used, so it can be used as a "not there" or
"deleted" marker or so.

IDs for deleted objects are not reused, but objects can be "revived" under
their old ID which is rare but does happen.

Normal OSM data doesn't have negative IDs, they are used sometimes in certain
application but are not supported in osm2pgsql, we don't need them.

Sometimes non-OSM-data is added to OSM data using higher ID ranges, we don't
have to support that use case, but if we can do so without a lot of extra work,
we probably should.

The 64bit ID space is more than we'll ever need (famous last words). Currently
we have about 1.5 billion way IDs, so 31 bit is still enough but soon it will
not be any more. Any development now has to allow more bits than that. There
are about 14 billion nodes IDs, so for nodes we need 34 bits. There are only 20
million relation IDs, so that would currently need only 25 bits. Using 31 bits
for relation IDs is probably okay for the forseeable future.

With 56bit IDs we can store more than 100 objects for each square meter of the
planet, be it on land or in water. Somewhat more realistically 40 bits might
already be plenty, especially considering that at that scale our whole data
model will probably break down. 40 bits would need 5 bytes, so we'll have 3
bytes per ID that we can use for other data.

## Versions

Versions are counted from version 1, 0 means no version is available in OSM
data, so we can use that special number for something else. Most objects never
change, so low version numbers are the norm, this is only somewhat different
for relations where we can see quite a lot of changes. Version numbers in the
thousands are not uncommon.

Avarage version numbers for nodes is 1.2, for ways 1.7, and for relations 3.8.
Still, over half the relations have never changed.

Varint-encoding of versions therefore looks promising. We might even be able
to go further, because version 1 is much more common (about 85% of nodes and
about 70% of ways have version 1), reducing storage to less than 1 byte per
object.

## Timestamps

The creation timestamp is usually stored as a 64 bit signed integer counting
the seconds since January 1 1970. Using 32 bit signed integers are enough until
2035, which is uncomfortably near, but because OSM was only invented in 2004 we
can use unsigned integers which gives us until 2106. This is used by Osmium
internally.

If we want to save even more, we can shift the epoch from 1970 to 2000 or 2004.
But that doesn't give us much. Using 24 bit we can't even store the seconds for
a single year. So 4 bytes is probably the practical limit.

IDs are given out in sequence and most objects never changed, so IDs correlate
really well with timestamps. Storing timestamps for consecutive OSM objects
using delta encoding and varints is quite effective.

Links:

* [Osmium Timestamp implementation](https://github.com/osmcode/libosmium/blob/master/include/osmium/osm/timestamp.hpp)

## User IDs

There are only on the order of 10 million users, but about 24 million IDs have
been used, because users keep getting registered and then deleted because of
spam. So 24 bit is not enough, but 32 bit should be plenty.

Because users do edits in "bunches", objects near each other have a much better
chance of being from the same user than from some other random user. If we
store several objects with consecutive IDs in some kind of block, it might make
sense to create a per-block dictionary of user IDs.

The user ID zero is used for anonymous edits (which are no longer allowed but
were historically) or when the OSM file doesn't contain any user ids.

Links:

* [User stats](https://wiki.openstreetmap.org/wiki/Stats#Accumulated_registered_users_(linear_scale))


## User Names

OSM files contain user names in addition to user IDs, but that's essentially
the same information. We can store the mapping from user IDs to user names
once if needed.

Note that usernames can change, but that change can't be detected unless a
change file with the old user ID and the new user name comes in.

Osm2pgsql-based applications don't use usernames usually, so it is probably not
worth to track them in the middle. The user name can still be exposed to the
Lua code so users can write a Lua config file that takes care of that.

## Tags

Tags consist of a key and a value, both can contain a maximum of 255 unicode
characters. Worst case they need 1024 bytes each, but usually they are much
smaller. Most objects have no or just a few tags, but some have hundreds of
tags.

Tag keys, and to a lesser extent, tag values are often from a relatively small
set of strings. There are nearly 4 billion tags in the database, but only about
110,000 distinct keys and about 190 million distinct values. The two most
common keys (`building` and `source`) alone cover already more than a billion
tags, the 50 most common cover 3 billion tags. The 250 or so most common
key/value combinations cover about 2 billion tags.

So some kind of dictionary-based storage probably makes sense. On the other
hand the long tail of keys and values is rather long, so we still need to
efficiently store the uncommon tags.

The list of most common keys is reasonably stable over time. So creating a
dictionary once on import and using that for years should be okay. For values
this is a bit different because certain values can go from 0 to very popular
quickly, especially something like an import source or date. If data is cleaned
up in OSM, very common values might vanish in the future.

## Object Types

OSM has three object types: nodes, ways, and relations. Although they look
quite similar in some regards, they are quite different in many aspects. Nodes
are small, often don't have any tags, and most never change. Ways usually take
up most of processing time and storage space, because there are so many and
they can be larger. Relations can be huge and change quite often, but there are
comparatively few of them.

Object are always stored in OSM data files and in OSM change files in the order
nodes, then ways, then relations, each ordered by ID.

Ways refer back to nodes, and we can be sure we have seen all nodes before the
ways. Relations can refer to nodes, ways, and other relations. We can be sure
we have seen all node and way members, but we can not be sure we have seen all
relation members! So working with more complex relation data probably means
some kind of two-stage processing, reading in all data first and then resolving
connections between relations.

## Nodes

Node locations can be stored in 2 x 32 bit. To be more exact the latitude (y
coordinate) gives us one free bit, because it only goes from -90° to +90°
unlike the longitude which goes from -180° to +180°. Libosmium already has
support for using that extra bit for something else.

Most nodes don't have any tags, less than 3% do have tags.

Locations of consecutive nodes are often near each other. The PBF file format
uses delta- and varint-encoding to profit from that.

*(Following output is from tools available in
[osmium-surplus](https://github.com/osmcode/osmium-surplus)).*

```
> osp-stats-way-nodes planet.osm.pbf
nodes: 10684738551
ways: 1199224443
relations: 14432595
nodes with tags: 289717070 (2% of all nodes)
nodes in way: 10509202728 (98% of all nodes)
nodes with tags in way: 115516995 (1% of all nodes) (39% of tagged nodes)
nodes in multiple ways: 1180384620 (11% of all nodes)
nodes in relation: 14089115 (0% of all nodes)
```

Most nodes are in a single way, some are in more ways. As I am writing this,
the maximum number of ways a node is in is 106! Lots of ways going through a
single node can happen in 3D mapping.

```
> osp-stats-way-nodes-idx planet.osm.pbf
[...]
Largest node id: 13903688409
Extra vector size: 2216909506 entries
Empty node slots: 3394485682 (24% of all slots)
Number of ways per node -> Count:
  1: 10509202727
  2: 1622962637
  3: 208768862
  4: 42434930
  5: 8422201
  6: 2085391
  7: 494503
  8: 151245
  9: 47971
  10: 18313
  11: 8540
  12: 5760
  13: 3709
  14: 2692
  15: 2025
  16: 1619
  17: 992
[...]
  100 or more: 1

First 10 nodes that are in more than 50 ways:
(Showing node id and the number of ways the node is in.)
10043974910 (106)
8954156928 (76)
13621618635 (74)
8954157432 (74)
8954156830 (74)
10043974904 (70)
8954146220 (70)
9966068538 (68)
8745886293 (65)
6348338529 (64)
```

## Ways

Ways store a list of node IDs with a maximum of 2000 node IDs. In the history
data there are ways with more node IDs, from before that limit was introduced.
The maximum there is 49189. To be able to work with historic data we should
support this if possible. A count would fit comfortably in 2 bytes. More than
99% of ways have less than 128 nodes in them, so varint encoding could save
us a byte here. Note that while it doesn't make much sense, ways with a single
node are allowed and do exist. Ways without nodes can not be created any more
but there might be some in the history data.

Node IDs in ways are aften consecutive or at least close to each other, delta
encoding plus varint encoding is probably useful.

About 2% of ways don't have any tags.

## Relations

Relations have a list of members with a maximum of 32000 members. Historically
there were six relations with more members before the limit was introduced
in February 2022, the largest had 220,433 members. We'll probably don't have
to support these very few special cases. The count can fit in 2 bytes, 98% of
all relations have fewer than 128 members, so varint encoding could save us
a byte.

A relation with zero members is allowed though not really useful. But they
do exist.

Each member is a type (node, way, or relation), an ID, and a free-form text for
the role. The type could easily be stored with the ID, we'd only need 2 bits
for that.

There are about 25,000 distinct roles, although only a few hundred of them
are actually used often enough to be interesting. The empty role is quite
common and must be supported. Most relation types have only very few common
roles.

Relations almost always have a `type` tag, the type(s) and typical number
(range) of members as well as common roles depend on the relation type. But
there are always exceptions we have to support.

Relations change much more often then other object types.

