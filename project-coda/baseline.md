---
title: Baseline
layout: coda
---

Out goal is to optimize storage requirements for the osm2pgsql middle. To
compare various solutions we need a baseline to compare to, the current
solution. And we need a "stretch goal", some numbers that tell us how close we
are to some theoretical "best" solution.

## Current Space Requirements

For a planet import with the current database middle we need about (all numbers
in GiB):

    254 ways
     59 ways index
      7 rels
      6 rels index
     45 nodes (optional)
      7 nodes index (optional)
    105 flat nodes
    ===
    483 total (~ 5.3x OSM PBF file)

These numbers are from a fresh import (using a 92 GiB planet file from July
2026).

Note that this is from a fresh import, PostgreSQL databases tend to grow over
time.

When the option `--extra-attributes` is used, OSM object attributes are also
stored. This isn't needed for most use cases, but we want to support it as an
option. Note that attributes are not stored for nodes without tags if the
flat node file is used.

In this case disk requirements are (all numbers in GiB):

    281 ways
     59 ways index
      8 rels
      6 rels index
     51 nodes (optional)
      7 nodes index (optional)
    105 flat nodes
    ===
    517 total (~ 5.6x OSM PBF file)

The factor that compares the data with the OSM PBF input file is handy to
compare what might happen with smaller extracts, but keep in mind that the
relation is not linear. In the case of the flat node file: It will always
have the same size, regardless of input!

Without flat node file we need 767 GiB for the nodes plus another 242 GiB for
the primary key index, so just over a TiB of disk space just for the nodes!
This needs so much disk space and is so much slower in processing that it is
probably never used.

## Minimum Space Requirements

It is impossible to know what the minimum achievable space requirement is. But
we can try to estimate this from various sources.

The first source is the PBF-encoded planet file. This format is quite clever
and uses many tricks to make the data as compact as possible. But the format
is not updatable, any updatable format will necessarily be bigger. A current
planet file has about 92 GiB, it contains all objects with all their attributes.

Removing the attributes (which we don't need for most osm2pgsql use cases), the
planet file is still 73 GiB.

As a second source for a number we can use the numbers from Imposm3, because it
has a very similar goal and needs basically the same data and indexes as
osm2pgsql. Imposm3 needs about 149 GiB (~ 1.6x the OSM PBF or ~ 2x compared to
the PBF file without attributes). See the [remarks about Imposm3 for
details]({% link project-coda/imposm.md %}). Imposm3 never stores attributes!

