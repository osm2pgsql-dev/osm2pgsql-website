---
chapter: 11
title: Tips & Tricks
---

The flex output allows a wide range of configuration options. Here
are some extra tips & tricks.

### Using `create_only` Columns for Postprocessed Data

Sometimes it is useful to have data in table rows that osm2pgsql can't create.
For instance you might want to store the center of polygons for faster
rendering of a label.

To do this define your table as usual and add an additional column, marking
it `create_only`. In our example case the type of the column should be the
PostgreSQL type `GEOMETRY(Point, 3857)`, because we don't want osm2pgsql to
do anything special here, just create the column with this type as is.

```lua
polygons_table = osm2pgsql.define_area_table('polygons', {
    { column = 'tags', type = 'hstore' },
    { column = 'geom', type = 'geometry' },
    { column = 'center', sql_type = 'GEOMETRY(Point, 3857)', create_only = true },
    { column = 'area', type = 'area' },
})
```

After running osm2pgsql as usual, run the following SQL command:

```sql
UPDATE polygons SET center = ST_Centroid(geom) WHERE center IS NULL;
```

If you are updating the data using `osm2pgsql --append`, you have to do this
after each update. When osm2pgsql inserts new rows they will always have a
`NULL` value in `center`, the `WHERE` condition makes sure that we only do
this (possibly expensive) calculation once.

### Accessing Environment Variables from Lua

In Lua scripts you can access environment variables with `os.getenv("VAR")`.
The Lua config scripts that osm2pgsql uses are normal Lua scripts, so you
can do that there, too.

### Logging Memory Use of Lua Scripts

Lua scripts can use quite a lot of memory if you are not careful. This is
usually only a problem when using [two-stage processing](#stages). To monitor
how much memory is currently used, can use this function:

```lua
function create_memory_reporter(filename, frequency)
    local counter = 0
    local file = io.open(filename, 'w')
    file:write('timestamp,counter,mbyte\n')

    return function()
        if counter % frequency == 0 then
            local mem = collectgarbage('count')
            local ts = os.date('%Y-%m-%dT%H:%M:%S,')
            file:write(ts .. counter .. ',' .. math.ceil(mem / 1024) .. '\n')
            file:flush()
        end
        counter = counter + 1
    end
end
```

Then use it to create one or more `memory_reporter`s. The first argument
is the output file name, the second specifies after how many process callbacks
it should trigger the output. Make sure this number is not too small,
otherwise processing will become quite slow.

Here is an example use for the `process_node` callback:

```lua
local mr = create_memory_reporter('/tmp/osm2pgsql-lua-memlog.csv', 10000)

function osm2pgsql.process_node(object)
    mr()
    ...
end
```

You can have one memory reporter for nodes, ways, and relations together or
have separate ones.

