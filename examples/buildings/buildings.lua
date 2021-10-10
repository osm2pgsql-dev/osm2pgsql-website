
local buildings = osm2pgsql.define_area_table('buildings', {
    -- Define an autoincrementing id column, QGIS likes a unique id on the table
    { column = 'id', sql_type = 'serial', create_only = true },
    { column = 'geom', type = 'polygon' },
})

function osm2pgsql.process_way(object)
    if object.is_closed and object.tags.building then
        buildings:add_row({
            geom = { create = 'area' }
        })
    end
end

function osm2pgsql.process_relation(object)
    if object.tags.type == 'multipolygon' and object.tags.building then
        buildings:add_row({
            -- The 'split_at' setting tells osm2pgsql to split up MultiPolygons
            -- into several Polygon geometries.
            geom = { create = 'area', split_at = 'multi' }
        })
    end
end

