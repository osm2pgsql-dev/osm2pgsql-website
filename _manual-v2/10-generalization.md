---
chapter: 10
title: Generalization
---

*Experimental*{: .experimental} Osm2pgsql has
some limited support for generalization. See [the generalization project
page]({% link generalization/index.md %}) for some background and details.
**This work is experimental and everything described here might change without
notice.**

For the generalization functionality the separate program `osm2pgsql-gen` is
provided. In the future this functionality might be integrated into `osm2pgsql`
itself. The same Lua configuration file that is used for osm2pgsql is also used
to configure the generalization. Generalization will only work together with
the *flex* output.

**The documentation in this chapter is incomplete. We are working on it...**

### Overview

Generalization is the process by which detailed map data is selected,
simplified, or changed into something suitable for rendering on smaller scale
maps (or smaller zoom levels). In osm2pgsql this is done with a separate
program after an import or update finished. Data is processed in the database
and/or read out of the database and processed in osm2pgsql and then written
back.

The end result is that in addition to the usual tables created and filled
by osm2pgsql you have a set of additional tables with the generalized data.

Generalization is currently only supported for Web Mercator (EPSG 3857). This
is by far the most common use case, we can look at extending this later if
needed.

Osm2pgsql supports several different strategies for generalization which use
different algorithms suitable for different types of data. Each strategy has
several configuration options. See the next section for general options used
by most strategies and the section after that for all the details about the
strategies.

### Configuration

All tables needed for generalized data have to be configured just like any
table in osm2pgsql. Currently there are some restrictions on the tables:

* The input and output tables must use the same schema.
* The geometry column used must have the same name as the geometry column
  in the table used as input for a generalizer.
* Output tables for tile-based generalizers must have `ids` set to `tile`,
  which automatically ceates `x` and `y` columns for the tile coordinates.
  An index will also be created on those columns after generalization.

To add generalization to your config, add a callback function
`osm2pgsql.process_gen()` and run generalizers in there:

```lua
function osm2pgsql.process_gen()
    osm2pgsql.run_gen(STRATEGY, { ... })
end
```

Replace `STRATEGY` with the strategy (see below) and add all parameters to the
Lua table.

The following parameters are used by most generalizers:

| Parameter   | Type | Description |
| ----------- | ---- | ----------- |
| name        | text | Identifier for this generalizer used for debug outputs and error message etc. |
| debug       | bool | Set to `true` to enable debug logging for this generalizer. Debug logging must also be enabled with `-l, --log-level=debug` on the command line. |
| schema      | text | Database schema for all tables. Default: `public`. |
| src_table   | text | The table with the input data. |
| dest_table  | text | The table where generalizer output data is written to. |
| geom_column | text | The name of the geometry column in the input and output tables (default: `geom`). |
{:.desc}

For more specific parameters see below.

You can also run any SQL command in the `process_gen()` callback with the
`run_sql()` function:

```lua
osm2pgsql.run_sql({
    description = 'Descriptive name for this command for logging',
    sql = "UPDATE foo SET bar = 'x'"
})
```

The following fields are available in the `run_sql()` command:

| Parameter   | Type                   | Description |
| ----------- | ---------------------- | ----------- |
| description | text                   | Descriptive name or short text for logging. |
| sql         | text or array of texts | The SQL command to run. The `sql` field can be set to a string or to an array of strings in which case the commands in those strings will be run one after the other. |
| transaction | bool                   | Set to `true` to run the command(s) from the `sql` field in a transaction (Default: `false`). |
| if_has_rows | text                   | SQL command that is run first. If that SQL command returns any rows, the commands in `sql` are run, otherwise nothing is done. This can be used, to trigger generalizations only if something changed, for instance when an expire table contains something. Use a query like `SELECT 1 FROM expire_table LIMIT 1`. Default: none, i.e. the command in `sql` always runs. |
{:.desc}

### Generalization Strategies

There are currently two types of strategies: Some strategies always work on all
data in the input table(s). If there are changes in the input data, the
processing has to restart from scratch. If you work with updates, you will
usually only run these strategies once a day or once a week or so. In general
those strategies make only sense for data that doesn't change that often (or
where changes are usually small) and if it doesn't matter that data in smaller
zoom levels are only updated occasionally.

The other type of strategy uses a tile-based approach. Whenever something
changes, all tiles intersecting with the change will be re-processed. Osm2pgsql
uses the existing [expire mechanism](#expire) to keep track of what to change.

#### Strategy `builtup`

This strategy derives builtup areas from landuse polygons, roads and building
outlines. It is intended to show roughly were there are urban areas. Because
it uses input data of several diverse types, it works reasonably well in
different areas of the world even if the landuse tagging is incomplete.

This strategy is tile-based. Internally it uses a similar approach as the
`raster-union` strategy but can work with several input tables.

Parameters used by this strategy (see below for some additional general
parameters):

| Parameter    | Type | Description |
| ------------ | ---- | ----------- |
| src_tables   | text | Comma-separated list of input table names in the order landuse layer, buildings layer, roads layer. |
| image_extent | int  | Width/height of the raster used for generalization (Default: 2048). |
| image_buffer | int  | Buffer used around the raster image (default: 0). |
| min_area     | real | Drop output polygons smaller than this. Default: off |
| margin       | real | The overlapping margin as a percentage of `image_extent` for raster processing of tiles. |
| buffer_size  | text | Amount by which polygons are buffered in pixels. Comma-separated list for each input file. |
| turdsize     | int  | |
| zoom         | int  | Zoom level. |
| make_valid   | bool | Make sure resulting geometries are valid. |
| area_column  | text | Column name where to store the area of the result polygons. |
{:.desc}

See [this blog
post](https://blog.jochentopf.com/2022-12-23-deriving-built-up-areas.html){:.extlink}
for some background.

#### Strategy `discrete-isolation`

When rendering a map with many point features like cities or mountain peaks it
is often useful to only put the most important features on the map. Importance
can be something like the number of people living in a city or the height of a
peak. But if only the absolute importance is used, some areas on the map will
get filled with many features, while others stay empty. The *Discrete
Isolation* algorithm can be used to calculate a more relative measure of
importance which tends to create a more evenly filled map.

This strategy always processes all features in a table.

Parameters used by this strategy (see below for some additional general
parameters):

| Parameter         | Type | Description |
| ----------------- | ---- | ----------- |
| id_column         | text | The name of the id column in the source table. |
| importance_column | text | The column in the source table with the importance metric. Column type must be a number type. |
{:.desc}

The `src_table` and `dest_table` have always to be the same.

You must have an index on the id column, otherwise this will be very slow! Set
`create_index = 'always'` in your source table configuration.

You must have the following columns in your table. This is currently not
configurable:

| Column    | Type | Description |
| --------- | ---- | ----------- |
| discr_iso | real | Discrete isolation value |
| irank     | int  | Importance rank |
| dirank    | int  | Discrete isolation rank |
{:.desc}

Use these column definitions in your config file to add them:

```
{ column = 'discr_iso', type = 'real', create_only = true },
{ column = 'irank', type = 'int', create_only = true },
{ column = 'dirank', type = 'int', create_only = true },
```

See [this blog
post](https://blog.jochentopf.com/2022-12-19-selecting-settlements-to-display.html){:.extlink}
for some background.

#### Strategy `raster-union`

This strategy merges and simplifies polygons using a raster intermediate. It
is intended for polygon layers such as landcover where many smaller features
should be aggregated into larger ones. It does a very similar job as the
`vector-union` strategy, but is faster.

This strategy is tile-based.

Parameters used by this strategy (see below for some additional general
parameters):

| Parameter       | Type | Description |
| --------------- | ---- | ----------- |
| image_extent    | int  | Width/height of the raster used for generalization (Default: 2048). |
| margin          | real | The overlapping margin as a percentage of `image_extent` for raster processing of tiles. |
| buffer_size     | text | Amount by which polygons are buffered in pixels (Default: 10). |
| zoom            | int  | Zoom level. |
| group_by_column | text | Name of a column in the source and destination tables used to group the geometries by some kind of classification (Optional). |
| expire_list     | text | |
| img_path        | text | Used to dump PNGs of the "before" and "after" images to a file for debugging. |
| img_table       | text | Used to dump "before" and "after" raster images to the database for debugging. The table will be created if it doesn't exist already. |
| where           | text | Optional WHERE clause to add to the SQL query getting the input data from the database. Must be empty or a valid SQL snippet. |
{:.desc}

Actual image extent used will be `image_extent + 2 * margin * image_extent`. `margin * image_extent` is rounded to nearest multiple of 64.

The `img_path` parameters can be set to help with debugging. Set `img_path` to
something like this: `some/dir/path/img`. Resulting images will be in the
directory `some/dir/path` and are named `img-X-Y-TYPE-[io].png` for input (`i`)
or output (`o`) images. The `TYPE` is the value from the `group_by_column`.

See [this blog
post](https://blog.jochentopf.com/2022-11-21-generalizing-polygons.html){:.extlink}
for some background.

#### Strategy `rivers`

This strategy is intended to find larger rivers with their width and aggregate
them into longer linestrings. **The implementation is incomplete and not usable
at the moment.**

This strategy always processes all features in a table.

Parameters used by this strategy (see below for some additional general
parameters):

| Parameter    | Type | Description |
| ------------ | ---- | ----------- |
| src_areas    | text | Name of the input table with waterway areas. |
| width_column | text | Name of the number type column containing the width of a feature. |
{:.desc}

See [this blog
post](https://blog.jochentopf.com/2023-01-30-generalizing-river-networks.html){:.extlink}
for some background.

#### Strategy `vector-union`

This strategy merges and simplifies polygons using vector calculations. It
is intended for polygon layers such as landcover where many smaller features
should be aggregated into larger ones. It does a very similar job as the
`raster-union` strategy, but is slower.

This strategy is tile-based.

Parameters used by this strategy (see below for some additional general
parameters):

| Parameter       | Type | Description |
| --------------- | ---- | ----------- |
| margin          | real | |
| buffer_size     | text | Amount by which polygons are buffered in Mercator map units. |
| group_by_column | text | Column to group data by. Same column is used in the output for classification. |
| zoom            | int  | Zoom level. |
| expire_list     | text | |
{:.desc}

#### Strategy `tile-sql`

Run some SQL code for each tile. Use {ZOOM}, {X}, and {Y} in the SQL command to
set the zoom level and tile coordinates.

This strategy is tile-based.

Parameters used by this strategy (see below for some additional general
parameters):

| Parameter       | Type | Description |
| --------------- | ---- | ----------- |
| sql             | int  | The SQL code to run. |
| zoom            | int  | Zoom level. |
{:.desc}


### Running osmp2gsql-gen

Here are the most important command line options:

| Command line option     | Description |
| ----------------------- | ----------- |
| -a, \--append           | Run in append (update) mode. Same option as with osm2pgsql. |
| -c, \--create           | Run in create (import) mode. Same option as with osm2pgsql. (This is the default.) |
| -j, \--jobs=JOBS        | Maximum number of threads to use. (Default: no threads.) |
| -l, \--log-level=LEVEL  | Set log level (`debug`, `info` (default), `warn`, or `error`). |
| \--log-sql              | Log all SQL commands send to the database. |
| \--middle-schema=SCHEMA | Use PostgreSQL schema SCHEMA for all tables, indexes, and functions in the middle. The schema must exist in the database and be writable by the database user. By default the schema set with `--schema` is used, or `public` if that is not set. Set this to the same value as used on the `osm2pgsql` command line. |
{:.desc}

Some strategies can run many jobs in parallel, speeding up processing a lot.
Use the `-j, --jobs` option to set the maximum number of threads. If nothing
else is running in parallel, try setting this to the number of available CPU
cores.

To specify which database to work on `osm2pgsql-gen` uses the same command line
options as `osm2pgsql`:

{% include_relative options/database.md %}

