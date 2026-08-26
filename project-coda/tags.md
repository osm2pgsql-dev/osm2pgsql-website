---
title: Storing Tags
layout: coda
---

There are several different ways of storing tags used in different programs and
file formats.

## Storing Tags as Strings

The simplest format just stores the keys and values as-is. This is, for
instance, used in the OSM XML format. Of course it takes a huge amount of
memory and only really makes sense if the data is either routinely compressed
(for instances with bzip2) or if this is just for temporary storage of small
amounts of data.

## Storing Tags using a Dynamic Dictionary

The OSM PBF storage format uses a block-based dynamic dictionary for all tags.
OSM objects are stored in blocks of typically 8000 objects. For each block a
string store maps all used keys and values to an integer. The rest of the data
only stores those integers. The string store can be sorted by frequency to use
smaller integers for often used strings for a slightly more efficient encoding
using varints. This block-based dictionary is quite efficient without the need
for a single dictionary for all the data which would be much more expensive to
create, but it does still involve a lot of duplication.

The [Geodesk]({% link project-coda/others.md %}#geodesk) format creates a
single dictionary of the most often used tags, the rest of the strings are
stored in a local dictionary in each tile.

Dynamic dictionaries adapt well to use with extracts, because tag frequency in
different extracts can be somewhat different.

But dynamic dictionaries also have several drawbacks: For best compression we
want the most often used tags to be compressed into smaller index values so
varint encoding of them is more efficient. But counting the occurances of each
string and sorting the dictionary means we essentially need two passes over the
data. And we need to store the dictionary somewhere and update it if new data
comes in. This makes the implementation a bit more difficult. And for strings
that are only used once, the extra overhead of storing a pointer into the
dictionary isn't optimal. The index values for the most often used keys can
easily fit into a single byte, for complete tags, an index using two bytes can
store all of the common values. But for a *complete* dictionary, you need two
bytes for key index values and three bytes for tag index values.

## Storing Tags using a Pre-Defined Dictionary

[Imposm3]({% link project-coda/imposm.md %}) uses a pre-defined dictionary of 6
keys (in the range U+0001 to U+001F) and 166 key/value combinations in the
Unicode private use area (U+E000 to U+F8FF). All other tags are stored as-is
(possibly escaping the first character (using U+FFFD) if it overlaps with one
of the special values used). (The
[code](https://github.com/omniscale/imposm3/blob/master/cache/binary/tags.go){:.extlink}.)

A pre-defined dictionary is simple to implement and the dictionary itself
doesn't have to be stored with the data. (Although we might want to store the
dictionary anyway to allow changing it in new versions of the software while
keeping the old database working). But it can't accommodate extracts so well.
If there is enough "free space" left for new tokens, the dictionary can later
be amended in a backwards-compatible manner if new popular tags appear.

## Storing Strings vs. Keys vs. Key/Value Combinations

Some solutions simply store all strings in OSM data (keys, values, user names,
and relation member roles) in a string store. The OSM PBF format works that
way. That does make sense for a dynamic dictionary, but if we use static
dictionaries we can split that up. User names are usually not needed for
osm2pgsql, and there aren't that many, so its not a big issue. There are very
few roles, having a dictionary for them should be easy. And there aren't that
many relations, so encoding isn't that important compared to tags.

So lets look at the tags: Many keys only come with a few common values
(`building=yes`, `highway=primary`, ...), some keys have lots of different
values (`name`, `ref`, `wikidata`, ...), some are "in between"
(`addr:housenumber` has lots of different values, but `addr:housenumber=1`
appears about 3.8 million times in the planet file. Most values are somewhat
"tied" to the keys, you don't see `building=motorway`. So it makes sense to
store keys and values as one entity for often used tags, but only store the
keys alone for often used keys that have many different values.

## Length of Keys and Values

In various case we need to either store the length of a tag key or value or
store a zero-byte at the end of that key or value. Keys and values can only be
255 unicode characters long, in UTF-8 encoding this means the maximum length is
about 1k. Storing the length can be more convenient, storing the length with
varint encoding means we usually only need a single byte and at most two.

Basically all keys have a length < 128, the exceptions are all broken keys.
(See also: https://taginfo.openstreetmap.org/reports/key_lengths#histogram .)

Only about 500,000 of all tag values have a length >= 128, together they appear
about 1.7 million times.

This means that storing the length with varint-encoding needs about 1.7 MByte
more than using a zero-byte as end-marker. That's negligible compared to the
overall storage of many GBytes for the tags. So we can use length fields and
still assume the length fields have only 1 byte in our calculations.

## Characters in Keys and Values

About 70% of keys only use lower case `a` to `z`, the underscore (`_`) and the
colon (`:`) character. If we add upper case characters `A` to `Z`,
the numbers `0` to `9` and the dash (`-`), we'll cover most of the common
keys. Most of the values are also only using ASCII characters.

It might be possible to invent some special compression based on this, but a
general compression algorithm such as Snappy or Zstd should be able to account
for this without extra effort on our side. And the general algorithms would
adapt better for special cases like a data extract for Japan that would contain
many more Japanese characters.

## Ignoring Keys

Some keys are almost always unused in typical osm2pgsql installations,
including some very common ones such as `source`, `source:date`, or
`start_date`. And they can have quite a lot of different values. So
it might make sense to not store those keys in the middle.

Or, the other way around, there might be certain specialized setups which only
need very few special keys, for them it might make sense to only store those
keys in the middle.

It might make sense to add an option to osm2pgsql allowing the user to set a
positive or negative list of keys which is used to remove any unwanted keys
directly when reading the data. This will not affect the choice of tag storage,
so we are not looking at the details here.

## Using Standard Compression Methods

Standard compression methods such as gzip, bzip2, zstd, etc. compress text
strings really well. So it stands to reason that this would work on tag keys
and values. Dumping all keys and tags from all objects into a file and
compressing this with some of these algorithms, file size is reduced from about
76 GByte to 6 to 10% of that size.

But the keys and values don't come in a large file and short strings by
themselves don't compress well. So it only makes sense to use such compression
methods on longer texts. In our case we can probably compress any dictionaries
or longer blocks of data. The LevelDB and RocksDB key-value stores have
built-in compression that could be very useful as the [numbers for Imposm3
show]({% link project-coda/imposm.md %}).

For short strings it might make sense to work with a [precomputed shared
dictionary](https://www.debugbear.com/blog/shared-compression-dictionaries){:.extlink}.
The ZSTD program can create and use such a shared dictionary.

## Comparing Approaches

To compare the various approaches mentioned above, I wrote a program called
`ome-tag-encoding` available in the
[osm2pgsql-middle-experiments](https://github.com/osm2pgsql-dev/osm2pgsql-middle-experiments){:.extlink}
repository. It stores keys/tags in various forms or simulates doing so to
create numbers for comparing the formats. Some settings can be changed on the
command line. The results are written to a Sqlite database which makes it
easy to run verious analyses on the resulting data.

The program generates some basic statistic:

object type|num untagged objects|num objects|num tags|tags per object|max tags per object|keys length|values length
-----------|-------------------:|----------:|-------:|--------------:|------------------:|----------:|------------:
node|10478439366|293209255|1014477213|3.46|543|10526619185|10230885259
way|22264864|1185557272|2857139805|2.41|198|24974023599|26382586685
relation|558|14597109|59373722|4.07|632|435872746|713517677
total|10500704788|1493363636|3930990740|2.63|632|35936515530|37326989621
{:.desc}

The program compares the following implementations:
* The one from Imposm3 with fixed key and key/value dictionary
* A key-only dictionary
* A key/value-only dictionary
* A combined key and key/value dictionary

Depending on the number of keys/values in the dictionary the values for the
resulting size of storing all tags for a planet differs, of course. But the
combined dictionary of common keys and common tags clearly works best. Here are
the numbers when using a dictionary with the 7,128 most often used keys which
appear at least 1000 times in the planet file and the 20,000 most often used
tags:

dictionary type|data size (MByte)|compressed data size (MByte)|Compressed size in percent of uncompressed
---|---|---|---
imposm|54303|15671|29.0
key|45040|13459|30.0
tag|28236|10533|37.0
combined|21488|9341|43.0
{:.desc}

Compression used here is always Snappy, data is stored in blocks of 4096 bytes
and then compressed.

