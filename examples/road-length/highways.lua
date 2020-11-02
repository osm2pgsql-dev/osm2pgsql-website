
local tables = {}

tables.highways = osm2pgsql.define_way_table('highways', {
    { column = 'type', type = 'text' },
    { column = 'geom', type = 'linestring', projection = 4326 },
})

tables.boundaries = osm2pgsql.define_area_table('boundaries', {
    { column = 'tags', type = 'hstore' },
    { column = 'geom', type = 'geometry', projection = 4326 },
})

function osm2pgsql.process_way(object)
    if object.tags.highway then
        tables.highways:add_row{ type = object.tags.highway }
    end
end

function osm2pgsql.process_relation(object)
    if object.tags.boundary == 'administrative' then
        tables.boundaries:add_row{
            tags = object.tags,
            geom = { create = 'area' }
        }
    end
end

