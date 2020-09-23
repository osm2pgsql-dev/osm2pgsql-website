
local streets = osm2pgsql.define_way_table('streets', {
    { column = 'type',    type = 'text' },
    { column = 'name',    type = 'text' },
    { column = 'name_fr', type = 'text' },
    { column = 'name_nl', type = 'text' },
    { column = 'tags',    type = 'hstore' },
    { column = 'geom',    type = 'linestring' },
})

local get_highway_value = osm2pgsql.make_check_values_func({
    'motorway', 'trunk', 'primary', 'secondary', 'tertiary',
    'motorway_link', 'trunk_link', 'primary_link', 'secondary_link', 'tertiary_link',
    'unclassified', 'residential', 'pedestrian'
})

function osm2pgsql.process_way(object)
    local highway_type = get_highway_value(object.tags.highway)

    if not highway_type then
        return
    end

    if object.tags.area == 'yes' then
        return
    end

    streets:add_row({
        type    = highway_type,
        tags    = object.tags,
        name    = object.tags.name,
        name_fr = object.tags['name:fr'],
        name_nl = object.tags['name:nl'],
        geom    = { create = 'line' }
    })
end

