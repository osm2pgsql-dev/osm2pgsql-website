---
chapter: 23
appendix: D
title: Upgrading
---

Some osm2pgsql changes have slightly changed the database schema it expects. If
updating an old database, a migration may be needed. The migrations here assume
the default `planet_osm` prefix.

It is frequently better to reimport as this will also recluster the tables and
remove table or index bloat.

#### Upgrade to 1.5.0: Changes to Flex and Multi Outputs

The multi output has been removed. You should switch to the flex output.

The following changes to the flex output configuration might be necessary
when switching from versions <1.5.0 to >=1.5.0:

* When defining a database table in your Lua config file, each column
  definition has a `type` field. From version 1.5.0 on, the `type` field can
  only contain the types known to osm2pgsql. If you want to use generic SQL
  types, use the `sql_type` field instead. In most cases simply changing
  all occurances of `type` to `sql_type` for which you get an error when
  running osm2pgsql should be enough. See the [Defining
  Columns](#defining-columns) section of the Flex Output chapter for details.
* The flex output now has internal support for the `json` and `jsonb` data
  types. Lua data will be automatically converted to JSON. If you used a Lua
  JSON library to convert the data before, you need to simply remove the
  conversion code in your Lua file.

No re-import of the data is necessary.

#### Upgrade to 0.93: Unprojected Slim Coordinates

The method of storing coordinates in the middle (slim) tables has changed.
There is no migration and a reload is required.

#### Upgrade to 0.91: Default Projection

The default projection was moved from 900913 to 3857. This does not effect
users using `-l` or `-E`, but if using no projection options or `-m` a
migration is needed:

```sql
ALTER TABLE planet_osm_roads ALTER COLUMN way TYPE geometry(LineString,3857) USING ST_SetSRID(way,3857);
ALTER TABLE planet_osm_point ALTER COLUMN way TYPE geometry(Point,3857) USING ST_SetSRID(way,3857);
ALTER TABLE planet_osm_line ALTER COLUMN way TYPE geometry(LineString,3857) USING ST_SetSRID(way,3857);
ALTER TABLE planet_osm_polygon ALTER COLUMN way TYPE geometry(Geometry,3857) USING ST_SetSRID(way,3857);
```

#### Upgrade to: 0.88.0: `z_order` Changes

In version 0.88.0 the `z_order` logic in the pgsql output was changed,
requiring an increase in `z_order` values. To migrate to the new range of
values, run

```sql
UPDATE planet_osm_line SET z_order = z_order * 10;
UPDATE planet_osm_roads SET z_order = z_order * 10;
```

This will not apply the new logic, but will get the existing `z_orders` in the
right group of 100 for the new logic.

If you are not using the `z_orders` column, this change may be ignored.

#### Upgrade to: 0.87.0 Pending Removal

Version 0.87.0 moved the in-database tracking of pending ways and relations to
in-memory, for an increase in speed. This requires removal of the pending
column and a partial index associated with it.

```sql
ALTER TABLE planet_osm_ways DROP COLUMN pending;
ALTER TABLE planet_osm_rels DROP COLUMN pending;
```

#### 32 Bit to 64 Bit ID Migration

Old databases may have been imported with 32 bit node IDs, while current OSM
data requires 64 bit IDs. A database this old should not be migrated, but
reloaded. To migrate, the type of ID columns needs to be changed to `bigint`.

