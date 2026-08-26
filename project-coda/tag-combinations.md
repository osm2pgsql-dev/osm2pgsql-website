---
title: Tag Combinations
layout: coda
---

Some tag combinations are used quite often. Some of this is simply due to those
combinations making sense (like relations with `type=boundary` and
`boundary=administrative`), some of them are due to imports which used specific
combinations that are not that common otherwise (for instance there are
millions of objects tagged `building=yes`, `wall=no` from an import in France).
A lot of these imports also created specific `source` or related tags.

If we wanted to not only store tags but combinations of tags in some clever way
saving disk space, we'd need to identify common combinations of tags. In
general that's not so easy, because of the explosion of combinations on objects
with many tags. For that reason
[taginfo](https://taginfo.openstreetmap.org/){:.extlink} only shows the most
often used tag pairs.

There is a simpler way to approach this problem: Count all unique combinations
of *all* tags on all objects. So we only have one combination per object. This
way we don't find all the `amenity=restaurant`, `cuisine=italian` combinations
because most of them will have different `name` tags also, but it will find all
the objects only tagged with `building=yes` and
`source=microsoft/BuildingFootprints`. So this gives us an incomplete solution,
but might nevertheless be helpful.

I wrote a program called `ome-tag-combinations` to create that statistic,
available in the
[osm2pgsql-middle-experiments](https://github.com/osm2pgsql-dev/osm2pgsql-middle-experiments){:.extlink}
repository.

Here are the 10 most often seen combinations:

count   |tag combination
--------|--------------------------------------------------------------------|
32330297|{"building":"yes","source":"microsoft/BuildingFootprints"}
9805329 |{"highway":"service","service":"driveway"}
9663892 |{"source":"NRCan-CanVec-10.0","waterway":"stream"}
9108775 |{"natural":"water","source":"NRCan-CanVec-10.0"}
6864306 |{"building":"yes","source":"cadastre-dgi-fr source : Direction Générale des Impôts - Cadastre. Mise à jour : 2010"}
5595565 |{"building":"yes","source":"cadastre-dgi-fr source : Direction Générale des Impôts - Cadastre. Mise à jour : 2011"}
4933713 |{"building":"yes","source":"cadastre-dgi-fr source : Direction Générale des Impôts - Cadastre. Mise à jour : 2012"}
4568138 |{"footway":"sidewalk","highway":"footway"}
4333823 |{"highway":"residential","source":"maxar"}
4070396 |{"access":"private","highway":"service","service":"driveway"}
--------|--------------------------------------------------------------------|
{:.desc}

Together there are hundreds of millions of tags with common combinations. The
question is how we can profit from that? By necessity all the tags in common
combinations will also be in the list of common tags, so we can replace them
by an index into a dictionary. Most tags will need two bytes for encoding the
index, and because most combinations only combine two or three tags, this will
only save us two or four bytes per object, maybe an additional byte because
we don't need the "number of tags"-count any more.

If we add up all the savings from the combinations that appear at least 100,000
times, we'll get to about 680 MBytes. For the 10,000 most often seen
combinations its 850 MBytes. Compared to the overall tag storage which is in
the tens of GBytes this doesn't look like that much.

Also: All of this comes at a cost of some complexity and it has a problem with
long-term stability. Most of these specific combinations are from imports. As
time goes by it might well be that somebody decides to clean up all those
`source` tags, instantly making a dictionary entry superfluous. And chances are
that tagging will diverge, for instance when all those `highway=residential`
will get names or are changed into different types of `highway`.

And we might be able to get most of the effect without the extra effort and
without the long-term stability issue: If, after the dictionary-encoding of the
data blocks with tags, we use a general-purpose compression algorithm on top,
this algorithm should pick up on the patterns created by lots of objects right
next to each other from some import with the same tags and compress them.
Probably not quite as efficient as doing it ourselves, but it doesn't require
any extra work on our part.

So compared to [tag encoding]({% link project-coda/tags.md %}) in general, the
encoding of multiple tags together doesn't seem to be that useful.

