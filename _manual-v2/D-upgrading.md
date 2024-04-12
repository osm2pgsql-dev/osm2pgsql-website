---
chapter: 23
appendix: D
title: Upgrading
---

### Upgrading to 2.0.0

Version 2.0.0 has some larger changes compared to the version 1 series. If you
are using osm2pgsql in production, we recommend that you upgrade to version
1.11.0 first. Then run osm2pgsql as usual and read all the messages it prints
carefully. If there are any messages about deprecated functionality act on them
before upgrading to 2.0.0.

Upgrade information for older versions are in the [v1 manual]({% link
doc/manual-v1.html %}#upgrading).

**Middle table format**

: Only the new format for the middle tables (`osm_planet_nodes/ways/rels`) is
  supported. This only affects you if you use slim mode and update your database.
  If you don't have a table named `osm2pgsql_properties` in your database you
  need to reimport your database. If you have a table `osm2pgsql_properties`,
  look for the entry `db_format`. If that is set to `1`, you have to reimport
  your database. The command line option `--middle-database-format` was removed.

: Support for non-bucket way node indexes or non-standard bucket sizes for way
  node indexes have been removed. The way node index will now always use the
  bucket index which is much smaller than a regular index. If you are not
  using the default bucket way node index, you have to reimport. The command
  line option `--middle-way-node-index-id-shift` which set this was removed.

: If in doubt, reimport, old databases are probably bloated
  anyway, an occasional reimport helps with that. For more information about
  this see the [Middle chapter](#middle).

**Gazetteer output removed**

: The Gazetteer output was removed. Historically it was used for the Nominatim
  geocoder but that switched to using the flex output.

**Removed command line options**

: The command line options `--cache-strategy`, `--with-forward-dependencies`,
  have been removed. The command line option `-i`, `--tablespace-index` has been
  removed, use the `--tablespace-slim-index` and/or `--tablespace-main-index`
  options instead. The options `--middle-database-format` and
  `--middle-way-node-index-id-shift` were removed, see above.

: Generally the checks for command line options are a bit more
  strict, so some combinations might not work or show warnings.

**New system requirements**

: Support for older systems has been removed. On Linux you need at least glibc
  8 (for `std::filesystem`), versions of the proj library before version 6 are
  not supported any more. There is no dependency on the boost-property-tree
  library any more. Lua is now required, you can not build osm2pgsql without
  it any more.

**Switching from `add_row()` to `insert()`**

: If you are using the flex output and your Lua config file uses the `add_row()`
  function, you need to change your configuration. The `area` column type has
  also been removed because it only works with `add_row()`. See [this
  tutorial]({% link
  doc/tutorials/switching-from-add-row-to-insert/index.md %}) for all the
  details.

**Check that Lua functions on OSM object are called correctly**

: Check that functions in Lua code such as `object:as_point()` are called
  correctly using the colon-syntax, not as `object.as_point()`. A warning
  is printed once per function if this is not the case. We are trying to get
  in line with common Lua syntax here which will allow some improvements
  later on.

**Handling of untagged objects and object attributes has changed**

: The `-x` or `--extra-attributes` command line option did several things at
  once which made some processing much slower than it needed to be. From 2.0.0
  onwards the behaviour is different:

: OSM object attributes (version, timestamp, changeset, uid, user) will always
  be available in the flex Lua processing functions if those attributes are
  available in the input data.

: When the `-x` or `--extra-attributes` command line option is used the
  behaviour for the "psgql" output is the same. But when using the "flex"
  output, this option only means that the attributes are stored in the middle
  tables and are available in the flex Lua processing functions.

: Indepedent of the `-x` or `--extra-attributes` command line option, the
  processing functions `process_node|way|relation()` will never be called for
  untagged objects. Instead the functions `process_untagged_node|way|relation()`
  will be called, if available. It is up to the user to decide in which data
  they are interested in and define the functions accordingly.

**Pgsql output deprecated**

: The old "pgsql" output id deprecated now, it will be removed in the version 3
  series. This is still a few years off, but please start moving your
  configurations over to the "flex" output.

