
local buildings = osm2pgsql.define_area_table('buildings', {
    -- Define an autoincrementing id column, QGIS likes a unique id on the table
    { column = 'id', sql_type = 'serial', create_only = true },
    { column = 'geom', type = 'polygon', not_null = true },
}, { indexes = {
    -- So we get an index on the id column
    { column = 'id', method = 'btree', unique = true },
    -- If we define any indexes we don't get the default index on the geometry
    -- column, so we add it here.
    { column = 'geom', method = 'gist' }
}})

function osm2pgsql.process_way(object)
    if object.is_closed and object.tags.building then
        buildings:insert({
            geom = object:as_polygon()
        })
    end
end

function osm2pgsql.process_relation(object)
    if object.tags.type == 'multipolygon' and object.tags.building then
        -- From the relation we get multipolygons...
        local mp = object:as_multipolygon()
        -- ...and split them into polygons which we insert into the table
        for geom in mp:geometries() do
            buildings:insert({
                geom = geom
            })
        end
    end
end

