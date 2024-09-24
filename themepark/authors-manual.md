---
title: Themepark Author's Manual
---

# Themepark Author's Manual

This manual is for authors of Themepark themes and topics. You should also
refer to the [chapter on the Flex Output in the osm2pgsql manual]({% link
doc/manual.html %}#the-flex-output) which contains many details that are not
repeated here.

## Creating a Theme

Creating you own theme is easy. First, you need a name, we'll use `hotdog` in
this document. Always choose a name with only ASCII letters, digits, and
underscores; the first character can not be a digit. This way your theme name
will be valid Lua identifier.

1. Create a directory `hotdog`.
2. Create a directory `hotdog/topics`.
3. Create a file `hotdog/init.lua` with the following content:

```lua
local themepark = ...
local theme = {}

-- your code here

return theme
```

*(Add the three dots exactly as you see them above.)*

You can add any code common to your theme in that file. You can access
functions from the themepark framework through the `themepark` variable. Make
sure all variables are `local` to that script. Add anything you might need
outside the file to the `theme` table.

Now you are ready to add topics...

## Adding Topics to Your Theme

You'll need a name for each topic, we'll use `YOUR_TOPIC` in this document.
Always choose a name with only ASCII letters, digits, and underscores; the
first character can not be a digit. This way your topic name will be valid Lua
identifier.

To add a topic create a file `hotdog/topics/YOUR_TOPIC.lua`. Start the
file with this line:

```lua
local themepark, theme, cfg = ...
```

*(Add the three dots exactly as you see them above.)*

Now add your code. You can refer to the Themepark framework objects through the
`themepark` variable, refer to your theme object through the `theme` variable
and to the config variables set with the `add_topic()` call through the `cfg`
variable. All three are Lua tables.

## Content of a Topic File

A topic file will usually consist of these sections:

* Initialization and config code
* Function definitions used by the rest of the code
* Table definition(s)
* Definition of processing callbacks

All sections are optional.

## Defining a Table

Tables are defined with `themepark:add_table(SETTINGS)`. It has many of the
same settings as the underlaying `osm2pgsql.define_table()` function, but adds
some extra functionality.

Here are all the settings:

| Setting  | Description |
| -------- | ----------- |
| columns  | Column definitions, see below. |
| geom     | If this is a string, sets the type of the geometry column (`point`, `linestring`, ...); the column will be named `geom`. If this is a Lua table, use `column` key to define the name of the geometry column and `type` for the geometry type.  |
| external | Set this to `true` if the table is created outside osm2pgsql. |
| ids_type | See below. |
| indexes  | Index definitions. See [Flex manual]({% link doc/manual.html %}#defining-indexes) for details. |
| name     | The table name for the database and also used in the config file to refer to the table. |
| schema   | Schema override. Use option `schema` to set for all tables. |
| tags     | Set OSM tags used in this table (optional, used for `taginfo` plugin only). |
| tiles    | Set settings for tileservers (optional, used with tileserver plugins only).|
{:.desc}

The column definitions work just like in a normal [osm2pgsql flex config]({%
link doc/manual.html %}#defining-columns). But don't define a geometry column.
Use the `geom` setting instead. (If you want to define several geometry columns
use `geom` for the main one and add others as needed. But the extra geometry
columns will not get some of the special treatment the main geometry column
gets, such as for tile server configs.)

There is one optional extra field `tiles` in a column definition that allows
you to configure how this column is treated by the tile server plugins. If this
is set to `false`, this column will not appear in the tiles, if it is set to
`'minzoom'`, this column is expected to contain a zoom level and rows in this
table will only appear in the tile of that zoom level and above.

The `ids_type` defines what ID columns the table should get. For tables that
will be filled with data from nodes, ways, or relations, set this to `node`,
`way`, or `relation`, respectively. For tables that will be filled with area
data from ways or relations, set this to `area`. For tables that will be filled
from a mix of source types, set this to `any`. For tables created for
generalized data filled by any of the tile generalizers, use `tile`. Setting
`ids_type` will choose good defaults for id column names. If you need something
specific, you can also use the `ids` setting instead as described in the flex
manual. Set `ids_type = false` if you don't want any ids on a table, but
such tables can not be updated or expired automatically!

## Adding Support for Naming Policies

Instead of just defining the columns as a list, you can wrap your columns in
a call to `thempark:columns()` like this:

```{lua}
    columns = themepark:columns({
        --- ... put your columns here
    })
```

This allows it other topics to set extra columns to add to your tables.
Specifically this is used to add a name column or columns using several
`name-*` topics in the `core` theme. See the user manual for how this is
used.

## Defining Processing Functions

Processing functions are defined in each topic of each theme with the
`themepark:add_proc(TYPE, FUNC)` function. The following processing types
are available:

| Type                    | Plain osm2pgsql config equivalent     | Description |
| ----------------------- | ------------------------------------- | ----------- |
| node                    | `osm2pgsql.process_node()`            | Called for each (tagged) node. |
| way                     | `osm2pgsql.process_way()`             | Called for each (tagged) way.  |
| relation                | `osm2pgsql.process_relation()`        | Called for each (tagged) relation. |
| area                    | *none*                                | Called for ways or relations that are areas. |
| select_relation_members | `osm2pgsql.select_relation_members()` | Does the same thing as equivalent function, results are collected. |
| gen                     | `osm2pgsql.process_gen()`             | Generalization (see below). |
{:.desc}

All functions of type `node`, `way`, and `relation` defined in the different
topics are called in the order they were defined. The functions have two
parameters, the OSM object (just like in normal flex output callbacks) and a
`data` object that is initially an empty Lua table and that you can use to
store any kind of data you'll need again. (By convention you should store all
data of a specific theme in a sub-table under the name of that theme
(`data.theme = { mydata = 'foo' }`).) The data will be given to each function
of the same type called on the same object. If any of your function returns the
text `'stop'`, processing for that object will end there. You can also change
anything in the supplied "object", but beware that other themes might expect
the object to look in a certain way, so this should only done in specific well
documented cases.

The `area` function type behaves similarly to the `node`, `way`, and `relation`
types, but it is called for all ways and all relations that *describe an area*.
The functions `themepark:way_is_area(object)` and
`themepark:relation_is_area(object)` decide what counts as an area. You can
overwrite those functions if needed. By default closed ways are areas and all
relations tagged `type=multipolgon` or `type=boundary`. Inside our area callback
function you can use the `object:as_area()` function which is defined as either
`object:as_polygon()` (for ways) or as `object:as_multipolygon()` for relations.

Here is an example for a callback function that cleans up the `oneway` tag:

```lua
-- Get canonicalized version of 'oneway' tag
themepark:add_proc('way', function(object, data)
    if not data.mytheme then
        data.mytheme = {}
    end

    local ow = object.tags.oneway
    if ow then
        if ow == 'yes' or ow == 'true' or ow == '1' then
            data.mytheme.oneway = 1
        elseif ow == '-1' then
            data.mytheme.oneway = -1
        else
            data.mytheme.oneway = 0
        end
    end

    -- store in object tag only if you are sure other themes will understand this
    -- object.tags.oneway = tostring(data.mytheme.oneway)
end)
```

## Inserting Data

To insert data into a table, call the `themepark:insert(TABLE_NAME, ATTRS[,
TAGS[, DEBUG]])` function. It basically does the same job as the
`object:insert()` function in non-Themepark config files.

It has the following parameters:

| Parameter  | Description |
| ---------- | ----------- |
| TABLE_NAME | The name of the table as defined with `themepark:add_table()` |
| ATTRS      | A Lua table with the column names mapping to their values. (Use `geom` for the geometry column unless you have defined it with a different name.) |
| TAGS       | The tags straight from the OSM object. Optional, see [Debug mode](#debug-mode) below. |
| DEBUG      | A Lua table with any extra data to be stored in the debug column. Optional, see [Debug mode](#debug-mode) below. |
{:.desc}

## Naming Conventions

Themepark uses some conventions when naming things and proposes others to make
config files more consistent and easier to use.

* Id columns are named `node_id`, `way_id`, `relation_id` or `area_id` for
  the respective `ids_type` settings. For the `any` type, columns `osm_id`
  and `osm_type` are used. For `tile` type, columns `x` and `y` are used.
* Always use only letter a-z, numbers 0-9, and the underscore (`_`) for table
  and other names.
* Use a name starting with `expire_` for expire tables.
* Use suffix `_interim` for interim tables only used to calculate some internal
  data that is normally not shown. (Those tables will usually have setting
  `tiles = false`.)

## Helper Functions

The Themepark framework has a few helper functions:

| Function                       | Description |
| ------------------------------ | ----------- |
| themepark.expand_template(str) | Expand instances of `{schema}` and `{prefix}` in the input `str` to the settings of the same name and return the result. |
| themepark.with_prefix(name)    | Add configured prefix to a table name (if any) and return the full name. |
{:.desc}

## Debug Mode

For this to work you need to call `themepark:add_debug_info(ATTRS, TAGS, DEBUG)`
XXX.

## Customization Points

You can redefine the following functions in the Themepark framework to get
some special functionality. You should only do that in special cases! See the
source code for details.

| Function                     | Description |
| ---------------------------- | ----------- |
| themepark:ids_policy()       | Decides how `ids_type` settings are translated into column names. |
| themepark:way_is_area()      | Decides which ways are considered to be areas. |
| themepark:relation_is_area() | Decides which relations are considered to be area. |
{:.desc}

## Tileserver Plugins

Themepark can create a tileserver config for you based on the tables etc. that
you have defined. Currently plugins for the T-Rex and Tilekiln tile servers
are available.

The tile server config that you'll get will probably not be perfect, but it
will get you going. Please report any issues with it.

There are several places where you can define specific tile server behaviour.
The most important is the table definition. The `tiles` field can be set to
`false` to not export this table to tiles. This is useful for interim tables
that are only used to create other tables from. Or the `tiles` field is set
to a Lua object which can have the following fields:

| Field       | Type | Description |
| ----------- | ---- | ----------- |
| minzoom     | int  | Minimum zoom level the data from this table should be used for. |
| maxzoom     | int  | Maximum zoom level the data from this table should be used for. |
| xycondition | bool | |
| group       | text | Set to the name of another table to group tiles from this table with. See below. |
| simplify    | bool | Instruct the tileserver to simplify the geometries. Not supported by all tile servers. |
{:.desc}

Sometimes you have a table that is created not by osm2pgsql but from some other
process but you still want that table to show up in the tiles configuration.
Define the table with `themepark:add_table()` as described above and add the
setting `external = true`.

### Table Grouping

Sometimes it is useful to have different tables with related data for different
zoom levels, usually with one table with all the details for higher zoom levels
and other tables with generalized data for lower zoom levels. You can *group*
several database tables together to achieve this. The main table is defined
normally and will appear with its name in the tile, but give it a `minzoom`
setting. Then add the `group` setting to all other tables with the name of the
main table and their own `minzoom` and `maxzoom` settings.

